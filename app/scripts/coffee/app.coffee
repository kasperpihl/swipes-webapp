define [
	"jquery"
	"backbone"
	"localStorage"
	"js/model/extra/ClockWork"
	"js/viewcontroller/MainViewController"
	"js/controller/AnalyticsController"
	"js/router/MainRouter"
	"js/collection/Collections"
	"js/controller/SidebarController"
	"js/viewcontroller/ModalViewController"
	"js/viewcontroller/LeftSidebarViewController"
	"js/viewcontroller/TopbarViewController"
	"js/viewcontroller/RightSidebarViewController"
	"js/controller/ScheduleController"
	"js/controller/FilterController"
	"js/controller/SettingsController"
	"js/controller/SyncController"
	"js/controller/APIController"
	"js/controller/KeyboardController"
	"js/controller/BridgeController"
	"js/controller/UserController"
	"js/controller/WorkController"
	"js/model/extra/NotificationModel"
	"gsap"
	], ($, Backbone, BackLocal, ClockWork, MainViewController, AnalyticsController, MainRouter, Collections, SidebarController, ModalViewController, LeftSidebarViewController, TopbarViewController, RightSidebarViewController, ScheduleController, FilterController, SettingsController, SyncController, APIController, KeyboardController, BridgeController, UserController, WorkController, NotificationModel) ->
	class Swipes
		UPDATE_INTERVAL: 30
		UPDATE_COUNT: 0
		handleQueryString:(queryString) ->
			clean = false
			if queryString and queryString.href
				@href = queryString.href
				if history.pushState
					newurl = window.location.protocol + "//" + window.location.host + window.location.pathname
					if window.location.hash
						newurl += window.location.hash
					window.history.pushState({path:newurl},'',newurl)
				
		constructor: ->
			##@tags.fetch()
			$(window).focus @openedWindow
			$(window).blur @closedWindow
			$(window).on( "resize", @resizedWindow )

		manualInit: ->
			#@hackParseAPI()
			# Base app data
			@collections = new Collections()

			@bridge = new BridgeController()
			@analytics = new AnalyticsController()
			

			# Synchronization
			@settings = new SettingsController()
			@sync = new SyncController()
			@api = new APIController()
			@updateTimer = new ClockWork()

			# Keyboard/Shortcut handler
			@shortcuts = new KeyboardController()
			
			
		start: ->
			if @sync.lastUpdate?
				@collections.fetchAll()
				_.invoke(@collections.todos.models, "set", { selected: no } )
				@collections.todos.repairActionStepsRelations()
				@init()
			else
				Backbone.once( "sync-complete", @init, @ )
			@sync.sync()
		init: ->
			@cleanUp()
			@notificationModel = new NotificationModel({id: 1})
			@leftSidebarVC = new LeftSidebarViewController()
			@topbarVC = new TopbarViewController()
			@rightSidebarVC = new RightSidebarViewController()
			@modalVC = new ModalViewController()
			
			@mainViewController = new MainViewController()
			@router = new MainRouter()
			
			
			@scheduler = new ScheduleController()
			@sidebar = new SidebarController()

			@filter = new FilterController()
			@userController = new UserController()
			@workmode = new WorkController()

			Backbone.history.start( pushState: no )
			$(".load-indicator").remove()
			

			$('.search-result a').click( (e) ->
				swipy.filter.clearFilters()
				Backbone.trigger( "remove-filter", "all" )
				return false
			)
			@workmode.checkForWork()
			if @href
				switch @href
					when "keyboard" then @sidebar.showKeyboardShortcuts()
					
				@href = false

		cleanUp: ->
			#@stopAutoUpdate()
			##@tags?.destroy()
			@mainViewController?.destroy()
			@router?.destroy()
			@scheduler?.destroy()
			@sidebar?.destroy()
			@filter?.destroy()
			@settings?.destroy()

			# If we init multiple times, we need to make sure to stop the history between each.
			if Parse.History.started then Parse.history.stop()
		resizedWindow: ->
			Backbone.trigger("resized-window")
		closedWindow: ->
			Backbone.trigger("closed-window")
		openedWindow: ->
			Backbone.trigger("opened-window")
			if swipy?
				swipy.sync.sync()
				swipy.userController.fetchUser()
			