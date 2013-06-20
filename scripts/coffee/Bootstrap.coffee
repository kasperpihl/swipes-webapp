define ['controller/ViewController', 'router/MainRouter'], (ViewController, MainRouter) ->
	class Bootstrap
		constructor: ->
			@init()
		init: ->
			@viewController = new ViewController()
			@router = new MainRouter()

			Backbone.history.start { pushState: no }