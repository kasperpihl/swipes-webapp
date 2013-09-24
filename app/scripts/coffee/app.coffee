define [
	'controller/ViewController'
	'router/MainRouter'
	'collection/ToDoCollection'
	], (ViewController, MainRouter, ToDoCollection) ->
	class Swipes
		constructor: ->
			@todos = new ToDoCollection()
			@todos.on( "reset", @init, @ )
			@fetchTodos()
		init: ->
			@viewController = new ViewController()
			@router = new MainRouter()

			Backbone.history.start { pushState: no }
			
			$(".add-new input").focus()
		fetchTodos: ->
			@todos.fetch()