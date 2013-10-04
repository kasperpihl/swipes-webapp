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
				Backbone.trigger( "apply-filter", "tag", tag )
			else
				Backbone.trigger( "remove-filter", "tag", tag )
		render: ->
			

