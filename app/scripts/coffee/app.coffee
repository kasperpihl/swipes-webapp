define [
	"backbone"
	"model/ClockWork"
	"controller/ViewController"
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
	], (Backbone, ClockWork, ViewController, MainRouter, ToDoCollection, TagCollection, ListNavigation, TaskInputController, SidebarController, ScheduleController, FilterController, SettingsController, ErrorController) ->
	class Swipes
		constructor: ->
			@hackParseAPI()

			@errors = new ErrorController()
			@todos = new ToDoCollection()
			@updateTimer = new ClockWork()
			@todos.on( "reset", @init, @ )
			@fetchTodos()

		hackParseAPI: ->
			# Add missing mehods to Parse
			for method in ["where", "findWhere"]
				if not Parse.Collection::[method]?
					Parse.Collection::[method] = Backbone.Collection::[method]

		init: ->
			@cleanUp()

			@tags = new TagCollection()
			@viewController = new ViewController()
			@nav = new ListNavigation()
			@router = new MainRouter()
			@scheduler = new ScheduleController()
			@input = new TaskInputController()
			@sidebar = new SidebarController()
			@filter = new FilterController()
			@settings = new SettingsController()

			@tags.fetch()

			Parse.history.start( pushState: no )
		cleanUp: ->
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