define [
	'controller/ViewController'
	'router/MainRouter'
	'collection/ToDoCollection'
	'collection/TagCollection'
	'view/nav/ListNavigation'
	], (ViewController, MainRouter, ToDoCollection, TagCollection, ListNavigation) ->
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

			Backbone.history.start { pushState: no }
			
			$(".add-new input").focus()
		fetchTodos: ->
			@todos.fetch()