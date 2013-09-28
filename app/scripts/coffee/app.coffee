define [
	"controller/ViewController"
	"router/MainRouter"
	"collection/ToDoCollection"
	"collection/TagCollection"
	"view/nav/ListNavigation"
	"controller/ScheduleController"
	], (ViewController, MainRouter, ToDoCollection, TagCollection, ListNavigation, ScheduleController) ->
	class Swipes
		constructor: ->
			@todos = new ToDoCollection()
			@todos.on( "reset", @init, @ )
			@fetchTodos()
		init: ->
			@tags = new TagCollection()
			@viewController = new ViewController()
			@nav = new ListNavigation()
			@router = new MainRouter()
			@scheduler = new ScheduleController()

			Backbone.history.start { pushState: no }
			
			$(".add-new input").focus()
		fetchTodos: ->
			@todos.fetch()