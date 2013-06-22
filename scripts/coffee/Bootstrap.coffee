define [
	'controller/ViewController'
	'router/MainRouter'
	'collection/ToDoCollection'
	], (ViewController, MainRouter, ToDoCollection) ->
	class Bootstrap
		constructor: ->
			@init()
		init: ->
			@viewController = new ViewController()
			@router = new MainRouter()
			@collection = new ToDoCollection()

			Backbone.history.start { pushState: no }
			@update()
		update: ->
			@collection.fetch()