define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		el: "#add-task"
		events: 
			"submit": "triggerAddTask"
		initialize: ->
			@input = @$el.find "input"
			@input.focus()
		triggerAddTask: (e) ->
			e.preventDefault()
			return if @input.val() is ""

			Backbone.trigger( "create-task", @input.val() )
			@input.val("")
		remove: ->
			@undelegateEvents();
			@$el.remove()