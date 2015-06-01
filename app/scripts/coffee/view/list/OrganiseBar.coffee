define ["underscore"], (_) ->
	Backbone.View.extend
		el: ".organise-bar"
		events:
			"click .start-day-button": "startDay"
		constructor: ( obj ) ->
			Backbone.View.apply @, arguments
		initialize: (obj)->
			@listenTo( swipy.todos, "change:selected", @toggle )
		startDay: ->
			
		toggle: ->
			selectedTasks = swipy.todos.filter (m) -> m.get "selected"
			console.log selectedTasks.length
		kill: ->
			@undelegateEvents()
			@stopListening()