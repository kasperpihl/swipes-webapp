define ->
	Backbone.View.extend
		initialize: ->
			_.bindAll @
			
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

