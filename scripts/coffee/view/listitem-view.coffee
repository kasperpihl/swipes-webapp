define ['hammer'], (Hammer) ->
	Backbone.View.extend
		initialize: ->
			_.bindAll @
			@render()
		enableGestures: ->
			log "Enabling gestures for ", @model.toJSON()
			@hammer = Hammer(@el).on "drag", @handleDrag
		disableGestures: ->
			log "Disabling gestures for ", @model.toJSON()
		handleDrag: (e) ->
			# Figure out if we are draggin left or right
			val = if e.gesture.direction is "left" then e.gesture.distance * -1 else e.gesture.distance
			
			# Limit value to 80% of window width, so we don't push item off the screen
			if val > window.innerWidth * 0.8 then val = window.innerWidth * 0.8
			else if val < 0 - window.innerWidth * 0.8 then val = 0 - window.innerWidth * 0.8
			
			@$el.css "left", "#{val}px"
		render: ->
			@enableGestures()
			return @el
		remove: ->
			@destroy()
		destroy: ->
			@disableGestures()

