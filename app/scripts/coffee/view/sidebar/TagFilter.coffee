define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		events: 
			"click li": "toggleFilter"
		initialize: ->
			console.log "New Tag Filter view created"
		toggleFilter: (e) ->
			tag = e.currentTarget.innerText
			el = $( e.currentTarget ).toggleClass "selected"

			if el.hasClass "selected"
				console.log "Filter for ", tag
			else
				console.log "De-filter for ", tag

