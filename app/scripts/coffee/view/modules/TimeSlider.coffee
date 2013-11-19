define ["underscore", "backbone", "gsap-draggable", "slider-control", "momentjs"], (_, Backbone, Draggable, SliderControl) ->
	Parse.View.extend
		tagName: "div"
		className: "range-slider lobster"
		initialize: ->
			_.bindAll( @, "updateValue" )
			@listenTo( @model, "change:time", _.debounce( @updateSlider, 50 ) )
		getFloatFromTime: (hour, minute) ->
			( hour / 24 ) + ( minute / 60 / 24 )
		getTimeFromFloat: (val) ->
			# There are 1440 minutes in a day
			minutesTotal = 1440 * val

			# Set hour and minute. Limit to 23.55, so we don't move over to the next day
			if val < 1
				{ hour: Math.floor( minutesTotal / 60 ), minute: Math.floor( minutesTotal % 60 ) }
			else
				{ hour: 23, minute: 55 }
		getOpts: ->
			{ onDrag: @updateValue, onDragEnd: @updateValue }
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