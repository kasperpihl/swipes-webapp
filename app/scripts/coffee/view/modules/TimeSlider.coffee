define ["underscore", "backbone", "gsap-draggable", "slider-control", "momentjs"], (_, Backbone, Draggable, SliderControl) ->
	Backbone.View.extend
		tagName: "div"
		className: "range-slider lobster"
		initialize: ->
			_.bindAll( @, "updateValue" )
			@listenTo( @model, "change:time", _.debounce( @updateSlider, 50 ) )
		getFloatFromTime: (hour, minute) ->
			( hour / 24 ) + ( minute / 60 / 24 )
		getTimeFromFloat: (value) ->
			# There are 1440 minutes in a day
			minutesTotal = Math.ceil(1440 * value)

			# Set hour and minute. Limit to 23.55, so we don't move over to the next day
			if value is 0
				{ hour: 0, minute: 15 }
			else if value is 1
				{ hour: 23, minute: 45 }
			else
				{ hour: Math.floor( minutesTotal / 60 ), minute: Math.round( minutesTotal ) % 60 }
		getOpts: ->
			# +1 to amount of actual steps, to make the time from value get the true value.
			# For instance, in a 12-stepped slider we would the last time be 22:00 where we want 24:00,
			# so we add the extra step. We want 12 steps in-between 0-24, not 12 steps in total.
			#
			# 24 * 4 will give us a step every 15 minutes.
			{ onDrag: @updateValue, onDragEnd: @updateValue, steps: ( 24 * 4 ) + 1  }
		getStartVal: ->
			snoozes = swipy.settings.get "snoozes"
			day = snoozes.weekday
			result = @getFloatFromTime( day.morning.hour, day.morning.minute )
			return result
		updateValue: ->
			unless @model.get "userManuallySetTime" then @model.set( "userManuallySetTime", yes )
			time = @getTimeFromFloat @slider.value
			@model.unset( "time", { silent: yes } )
			@model.set( "time", time )
			@model.set( "timeEditedBy", "timeslider" )
		updateSlider: (model, time) ->
			return unless model.get( "timeEditedBy" ) isnt "timeslider"

			value = @getFloatFromTime( time.hour, time.minute )
			unless @slider?
				@slider = new SliderControl( @el, @getOpts(), value )
			else
				@slider.setValue value
		render: ->
			@$el.html "<div class='track'></div><div class='handle'></div>"
			return @
		remove: ->
			@undelegateEvents()
			@stopListening()
			@slider?.destroy()
			@$el.remove()