define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		el: ".action-bar"
		events: 
			"click .edit": "editTask"
		initialize: ->
			@shown = no
			@listenTo( swipy.todos, "change:selected", @toggle )
		toggle: ->
			if @shown
				if swipy.todos.filter( (m) -> m.get "selected" ).length is 0
					@hide()
			else
				if swipy.todos.filter( (m) -> m.get "selected" ).length is 1
					@show()
		show: ->
			@$el.removeClass "fadeout"
			@shown = yes

		hide: ->
			@$el.addClass "fadeout"
			@shown = no
		kill: ->
			@stopListening()
		editTask: (e) ->
			console.log "Edit task: ", arguments
