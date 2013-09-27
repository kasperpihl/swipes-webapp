define [
	"controller/ViewController"
	"router/MainRouter"
	"collection/ToDoCollection"
	"collection/TagCollection"
	"view/nav/ListNavigation"
	"view/scheduler/ScheduleOverlay"
	], (ViewController, MainRouter, ToDoCollection, TagCollection, ListNavigation, ScheduleOverlay) ->
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
			@scheduler = new ScheduleOverlay()

			Backbone.history.start { pushState: no }
			
			$(".add-new input").focus()
		fetchTodos: ->
			@todos.fetch()