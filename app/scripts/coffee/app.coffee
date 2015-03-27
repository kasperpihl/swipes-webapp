define [
	"jquery"
	"backbone"
	"localStorage"
	"js/model/ClockWork"
	"js/controller/ViewController"
	"js/controller/AnalyticsController"
	"js/router/MainRouter"
	"js/collection/ToDoCollection"
	"js/collection/TagCollection"
	"js/view/nav/ListNavigation"
	"js/controller/TaskInputController"
	"js/controller/SidebarController"
	"js/controller/ScheduleController"
	"js/controller/FilterController"
	"js/controller/SettingsController"
	"js/controller/ErrorController"
	"js/controller/SyncController"
	"js/controller/KeyboardController"
	"js/controller/BridgeController"
	"js/controller/UserController"
	"gsap"
	], ($, Backbone, BackLocal, ClockWork, ViewController, AnalyticsController, MainRouter, ToDoCollection, TagCollection, ListNavigation, TaskInputController, SidebarController, ScheduleController, FilterController, SettingsController, ErrorController, SyncController, KeyboardController, BridgeController, UserController) ->
	class Swipes
		UPDATE_INTERVAL: 30
		UPDATE_COUNT: 0
		constructor: ->
			#@hackParseAPI()
			@bridge = new BridgeController()
			@analytics = new AnalyticsController()
			@errors = new ErrorController()
			
			# Base app data
			@todos = new ToDoCollection()
			@tags = new TagCollection()

			# Synchronization
			@settings = new SettingsController()
			@sync = new SyncController()
			@updateTimer = new ClockWork()

			# Keyboard/Shortcut handler
			@shortcuts = new KeyboardController()
			
			##@tags.fetch()
			$(window).focus @openedWindow
		start: ->
			if @sync.lastUpdate?
				@tags.fetch()
				@todos.fetch()
				_.invoke(@todos.models, "set", { selected: no } )
				@todos.repairActionStepsRelations()
				@init()
				@todos.prepareScheduledForNotifications()
			else
				Backbone.once( "sync-complete", @init, @ )
			@sync.sync()
		isBusy: ->
			# Are any todos being saved right now?
			if @todos.length?
				for task in @todos.models when task._saving
					return yes

			# Are any tags being saved right now?
			if @tags.length?
				for tag in @tags.models when tag._saving
					return yes

			# Are any tasks being edited right now
			if location.href.indexOf( "edit/" ) isnt -1
				return yes

			# Are any tasks selected right now?
			if @todos.length
				if @todos.where( selected:yes ).length
					return yes

			return no
		init: ->
			@cleanUp()
			@viewController = new ViewController()
			@nav = new ListNavigation()
			@router = new MainRouter()
			@scheduler = new ScheduleController()
			@input = new TaskInputController()
			@sidebar = new SidebarController()
			@filter = new FilterController()
			@userController = new UserController()

			Backbone.history.start( pushState: no )

			$("body").removeClass "loading"

			$('.search-result a').click( (e) ->
				swipy.filter.clearFilters()
				Backbone.trigger( "remove-filter", "all" )
				return false
			)

			# $("")

			#@startAutoUpdate()

		###update: ->
			if not @isBusy()
				@fetchTodos()
				@UPDATE_COUNT++

			@lastUpdate = new Date()
			TweenLite.delayedCall( @UPDATE_INTERVAL, @update, null, @ )
		startAutoUpdate: ->
			TweenLite.delayedCall( @UPDATE_INTERVAL, @update, null, @ )
		stopAutoUpdate: ->
			TweenLite.killDelayedCallsTo @update###
			
		cleanUp: ->
			#@stopAutoUpdate()
			##@tags?.destroy()
			@viewController?.destroy()
			@nav?.destroy()
			@router?.destroy()
			@scheduler?.destroy()
			@input?.destroy()
			@sidebar?.destroy()
			@filter?.destroy()
			@settings?.destroy()

			# If we init multiple times, we need to make sure to stop the history between each.
			if Parse.History.started then Parse.history.stop()
		openedWindow: ->
			Backbone.trigger("opened-window")
			if swipy?
				swipy.sync.sync()
				swipy.userController.fetchUser()
			