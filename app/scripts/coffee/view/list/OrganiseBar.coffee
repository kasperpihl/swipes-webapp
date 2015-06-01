define ["underscore"], (_) ->
	Backbone.View.extend
		el: ".organise-bar"
		events:
			"click .start-day-button": "startDay"
			"click .back-button": "back"
		constructor: ( obj ) ->
			_.bindAll( @, "back" )
			Backbone.View.apply @, arguments
		initialize: (obj)->
			@listenTo( swipy.todos, "change:selected", @toggle )
			@toggle()
		back: ->
			@goBack(true)
			return false
		goBack: (trigger) ->
			newPath = "list/todo"
			if Backbone.history.fragment.indexOf("/organise") isnt -1
				newPath = Backbone.history.fragment.replace("/organise","")
			swipy.router.navigate(newPath, trigger)
		startDay: ->
			Backbone.trigger("schedule-all-but-selected")
			return false
		toggle: ->
			selectedTasks = swipy.todos.filter (m) -> m.get "selected"

			if selectedTasks.length
				@$el.find('.start-day-section').show()
				@$el.find('.counting-selected').show().find('.selected-label').html(""+selectedTasks.length)
			else 
				@$el.find('.start-day-section').hide()
				@$el.find('.counting-selected').hide()
		kill: ->
			@undelegateEvents()
			@stopListening()