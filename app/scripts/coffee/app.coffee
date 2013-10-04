define [
	"controller/ViewController"
	"router/MainRouter"
	"collection/ToDoCollection"
	"collection/TagCollection"
	"view/nav/ListNavigation"
	"controller/TaskInputController"
	"controller/SidebarController"
	"controller/ScheduleController"
	"controller/FilterController"
	"controller/ErrorController"
	], (ViewController, MainRouter, ToDoCollection, TagCollection, ListNavigation, TaskInputController, SidebarController, ScheduleController, FilterController, ErrorController) ->
	class Swipes
		constructor: ->
			@errors = new ErrorController()
			@todos = new ToDoCollection()
			@todos.on( "reset", @init, @ )
			@fetchTodos()
			
		init: ->
			@tags = new TagCollection()
			@viewController = new ViewController()
			@nav = new ListNavigation()
			@router = new MainRouter()
			@scheduler = new ScheduleController()
			@input = new TaskInputController()
			@sidebar = new SidebarController()
			@filter = new FilterController()
			
			unless Backbone.History.started 
				Backbone.history.start { pushState: no }
		fetchTodos: ->
			@todos.fetch()