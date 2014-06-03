define [
	"backbone"
	"model/ClockWork"
	"controller/ViewController"
	"controller/AnalyticsController"
	"router/MainRouter"
	"collection/ToDoCollection"
	"collection/TagCollection"
	"view/nav/ListNavigation"
	"controller/TaskInputController"
	"controller/SidebarController"
	"controller/ScheduleController"
	"controller/FilterController"
	"controller/SettingsController"
	"controller/ErrorController"
	"controller/SyncQueue"
	"controller/SyncController"
	"gsap"
	"localytics-sdk"
	], (Backbone, ClockWork, ViewController, AnalyticsController, MainRouter, ToDoCollection, TagCollection, ListNavigation, TaskInputController, SidebarController, ScheduleController, FilterController, SettingsController, ErrorController, SyncQueue, SyncController) ->
	class Swipes
		UPDATE_INTERVAL: 30
		UPDATE_COUNT: 0
		constructor: ->
			@hackParseAPI()

			@queue = new SyncQueue()
			@analytics = new AnalyticsController()
			@errors = new ErrorController()
			@todos = new ToDoCollection()
			@updateTimer = new ClockWork()

			

			@tags = new TagCollection()
			##@tags.once( "reset", => @fetchTodos() )
			@todos.once( "reset", @init, @ )

			##@tags.fetch()

			@sync = new SyncController()

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

			# Are we pushing changes to the server right now?
			if @queue.isBusy()
				return yes

			return no
		hackParseAPI: ->
			# Add missing mehods to Parse.Collection.prototype
			for method in ["where", "findWhere"]
				if not Parse.Collection::[method]?
					Parse.Collection::[method] = Backbone.Collection::[method]

		init: ->
			@cleanUp()

			@viewController = new ViewController()
			@nav = new ListNavigation()
			@router = new MainRouter()
			@scheduler = new ScheduleController()
			@input = new TaskInputController()
			@sidebar = new SidebarController()
			@filter = new FilterController()
			@settings = new SettingsController()

			Parse.history.start( pushState: no )

			$("body").removeClass "loading"
			# $("")

			@startAutoUpdate()

		update: ->
			if not @isBusy()
				@fetchTodos()
				@UPDATE_COUNT++

			@lastUpdate = new Date()
			TweenLite.delayedCall( @UPDATE_INTERVAL, @update, null, @ );
		startAutoUpdate: ->
			TweenLite.delayedCall( @UPDATE_INTERVAL, @update, null, @ );
		stopAutoUpdate: ->
			TweenLite.killDelayedCallsTo @update
		cleanUp: ->
			@stopAutoUpdate()
			@tags?.destroy()
			@viewController?.destroy()
			@nav?.destroy()
			@router?.destroy()
			@scheduler?.destroy()
			@input?.destroy()
			@sidebar?.destroy()
			@filter?.destroy()
			@settings?.destroy()
			@queue?.destroy()

			# If we init multiple times, we need to make sure to stop the history between each.
			if Parse.History.started then Parse.history.stop()
		fetchTodos: ->
			@sync.sync()