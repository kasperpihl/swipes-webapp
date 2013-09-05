define [
	'controller/ViewController'
	'router/MainRouter'
	'collection/ToDoCollection'
	], (ViewController, MainRouter, ToDoCollection) ->
	class Bootstrap
		constructor: ->
			@init()
		init: ->
			console.log "initialized app"

			###
			@viewController = new ViewController()
			@router = new MainRouter()
			@collection = new ToDoCollection()
			###

			Backbone.history.start { pushState: no }
			# @update()
			
			$(".add-new input").focus()
		update: ->
			@collection.fetch()