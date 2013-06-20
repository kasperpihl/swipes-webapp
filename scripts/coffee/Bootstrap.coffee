define ['controller/PageController', 'router/MainRouter'], (PageController, MainRouter) ->
	class Bootstrap
		constructor: ->
			@init()
		init: ->
			@pageController = new PageController()
			@router = new MainRouter()

			Backbone.history.start { pushState: no }