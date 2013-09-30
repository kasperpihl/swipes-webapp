define [
	"controller/ViewController"
	"router/MainRouter"
	"collection/ToDoCollection"
	"collection/TagCollection"
	"view/nav/ListNavigation"
	"controller/TaskInputController"
	"controller/ScheduleController"
	"controller/ErrorController"
	], (ViewController, MainRouter, ToDoCollection, TagCollection, ListNavigation, TaskInputController, ScheduleController, ErrorController) ->
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
			
			unless Backbone.History.started 
				Backbone.history.start { pushState: no }
		fetchTodos: ->
			@todos.fetch()