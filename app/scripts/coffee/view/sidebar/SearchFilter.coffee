define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		initialize: ->
			console.log "New Search Filter view created"