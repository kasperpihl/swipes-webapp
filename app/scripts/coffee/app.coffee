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
	"gsap"
	"localytics-sdk"
	], (Backbone, ClockWork, ViewController, AnalyticsController, MainRouter, ToDoCollection, TagCollection, ListNavigation, TaskInputController, SidebarController, ScheduleController, FilterController, SettingsController, ErrorController) ->
	class Swipes
		UPDATE_INTERVAL: 30
		UPDATE_COUNT: 0
		constructor: ->
			@hackParseAPI()

			@analytics = new AnalyticsController()
			@errors = new ErrorController()
			@todos = new ToDoCollection()
			@updateTimer = new ClockWork()

			@tags = new TagCollection()
			@tags.once( "reset", => @fetchTodos() )
			@todos.once( "reset", @init, @ )

			@tags.fetch()
		isSaving: ->
			if @todos.length?
				for task in @todos.models when task._saving
					return yes

			if @tags.length?
				for tag in @tags.models when tag._saving
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
			if not @isSaving()
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

			# If we init multiple times, we need to make sure to stop the history between each.
			if Parse.History.started then Parse.history.stop()
		fetchTodos: ->
			@todos.fetch()