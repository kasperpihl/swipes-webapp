define [
	'controller/ViewController'
	'router/MainRouter'
	'collection/ToDoCollection'
	'view/nav/ListNavigation'
	], (ViewController, MainRouter, ToDoCollection, ListNavigation) ->
	class Swipes
		constructor: ->
			@todos = new ToDoCollection()
			@viewController = new ViewController()
			@nav = new ListNavigation()
			@router = new MainRouter()

			Backbone.history.start { pushState: no }
			
			$(".add-new input").focus()
			
			@todos.fetch()