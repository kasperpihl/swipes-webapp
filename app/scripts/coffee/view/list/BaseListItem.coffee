define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		initialize: ->
			@content = @$el.find('.todo-content')
			@render()
		enableInteraction: ->
			
		disableInteraction: ->
			console.warn "Disabling gestures for ", @model.toJSON()
		render: ->
			@enableInteraction()
			return @el
		remove: ->
			@destroy()
			@model.off()
		destroy: ->
			@disableInteraction()
			console.log "CLEEEAAAANED!!!!!"

