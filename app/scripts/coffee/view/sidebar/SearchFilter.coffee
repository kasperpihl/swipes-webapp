define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		events: 
			"submit form": "search"
			"keyup input": "search"
			"change input": "search"
		initialize: ->
			console.log "New Search Filter view created"
			@input = $ "form input"
		search: (e) ->
			e.preventDefault()
			value = @input.val()

			eventName = if value.length then "apply-filter" else "remove-filter"
			Backbone.trigger( eventName, "search", value.toLowerCase() )