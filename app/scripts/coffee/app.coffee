define [
	"jquery"
	"underscore"
	"backbone"
	"localStorage"
	"collectionSubset"
	"js/model/extra/ClockWork"
	"js/viewcontroller/MainViewController"
	"js/controller/AnalyticsController"
	"js/router/MainRouter"
	"js/collection/Collections"
	"js/collection/slack/SlackCollections"
	"js/controller/SidebarController"
	"js/viewcontroller/ModalViewController"
	"js/viewcontroller/LeftSidebarViewController"
	"js/viewcontroller/TopbarViewController"
	"js/viewcontroller/RightSidebarViewController"
	"js/controller/ScheduleController"
	"js/controller/FilterController"
	"js/controller/SettingsController"
	"js/controller/SyncController"
	"js/controller/SlackSyncController"
	"js/controller/APIController"
	"js/controller/KeyboardController"
	"js/controller/BridgeController"
	"js/controller/OnboardingController"
	"js/controller/UserController"
	"js/controller/WorkController"
	"js/controller/SoundController"
	"js/model/extra/NotificationModel"
	"gsap"
	], ($, _, Backbone, BackLocal, ColSubset, ClockWork, MainViewController, AnalyticsController, MainRouter, Collections, SlackCollections, SidebarController, ModalViewController, LeftSidebarViewController, TopbarViewController, RightSidebarViewController, ScheduleController, FilterController, SettingsController, SyncController, SlackSyncController, APIController, KeyboardController, BridgeController, OnboardingController, UserController, WorkController, SoundController, NotificationModel) ->
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
			@isOpened = true
			_.bindAll(@, "openedWindow", "closedWindow")
			$(window).focus @openedWindow
			$(window).blur @closedWindow
			$(window).on( "resize", @resizedWindow )

		manualInit: ->
			#@hackParseAPI()
			# Base app data
			@collections = new Collections()
			@slackCollections = new SlackCollections()

			@bridge = new BridgeController()
			

			# Synchronization
			@settings = new SettingsController()
			@sync = new SyncController()
			@slackSync = new SlackSyncController()
			@api = new APIController()
			@updateTimer = new ClockWork()

			# Keyboard/Shortcut handler
			@shortcuts = new KeyboardController()
			
			
		start: ->
			@slackCollections.fetchAll()
			@slackSync.start()
			@collections.fetchAll()
			if @sync.lastUpdate? and localStorage.getItem("slackLastConnected")
				_.invoke(@collections.todos.models, "set", { selected: no } )
				@collections.todos.repairActionStepsRelations()
				@init()
				@sync.sync()
			else
				Backbone.once( "slack-first-connected", @sync.sync, @sync )
				Backbone.once( "sync-complete", @init, @ )
		init: ->
			@cleanUp()
			@analytics = new AnalyticsController()
			@analytics.logEvent("[Session] Opened App")

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
			@sound = new SoundController()
			@workmode = new WorkController()
			@onboarding = new OnboardingController()

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
			@onboarding.start()
		cleanUp: ->
			#@stopAutoUpdate()
			##@tags?.destroy()
			@mainViewController?.destroy()
			@router?.destroy()
			@scheduler?.destroy()
			@sidebar?.destroy()
			@filter?.destroy()
			@settings?.destroy()
			@sound?.destroy()

			# If we init multiple times, we need to make sure to stop the history between each.
			if Parse.History.started then Parse.history.stop()
		resizedWindow: ->
			Backbone.trigger("resized-window")
		closedWindow: ->
			Backbone.trigger("closed-window")
			@isWindowOpened = false

		openedWindow: ->
			Backbone.trigger("opened-window")
			@isWindowOpened = true
			@sync?.sync()
			