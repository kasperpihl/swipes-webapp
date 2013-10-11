define ["view/settings/BaseSubview", "gsap-draggable", "slider-control", "text!templates/settings-snoozes.html"], (BaseView, Draggable, SliderControl, Tmpl) ->
	BaseView.extend
		className: "snoozes"
		events:
			"click button": "toggleSection"
		initialize: ->
			BaseView::initialize.apply( @, arguments )
			_.bindAll( @, "setupSliders", "updateValue" )
			@transitionInDfd.then @setupSliders
		getFloatFromTime: (hour, minute) ->
			( hour / 24 ) + ( minute / 60 / 24 )
		getTimeFromFloat: (val) ->
			# There are 1440 minutes in a day
			minutesTotal = 1440 * val
			return { hour: Math.floor( minutesTotal / 60 ), minute: Math.floor( minutesTotal % 60 ) }
		getFormattedTime: (hour, minute, addAmPm = yes) ->
			if minute < 10 then minute = "0" + minute

			if addAmPm
				if hour is 0 then return "12:" + minute + " AM"
				else if hour <= 11 then return hour + ":" + minute + " AM"
				else if hour is 12 then return "12:" + minute + " PM"
				else return hour - 12 + ":" + minute + " PM"
			
			else
				return hour + ":" + minute
		getSliderVal: (sliderId) ->
			snoozes = swipy.settings.get "snoozes"

			switch sliderId
				when "start-day"
					@getFloatFromTime( snoozes.weekday.morning.hour, snoozes.weekday.morning.minute )
		setupSliders: ->
			startDayEl = @el.querySelector ".day .range-slider"
			startDayOpts = 
				onDrag: => @updateValue( "start-day", arguments... )
				onDragEnd: => @updateValue( "start-day", arguments... )
			
			@startDaySlider = new SliderControl( startDayEl, startDayOpts, @getSliderVal "start-day" )
		updateValue: (sliderId) ->
			snoozes = swipy.settings.get "snoozes"
			swipy.settings.unset( "snoozes", { silent: yes } )

			switch sliderId
				when "start-day"
					time = @getTimeFromFloat @startDaySlider.value
					@$el.find(".day button").text @getFormattedTime( time.hour, time.minute )

			swipy.settings.set( "snoozes", snoozes )		
		setTemplate: ->
			@template = _.template Tmpl
		render: ->
			console.log "Rendering snoozes"
			@$el.html @template { snoozes: swipy.settings.get "snoozes" }
			@transitionIn()
		toggleSection: (e) ->
			$(e.currentTarget.parentNode.parentNode).toggleClass "toggled"
		cleanUp: ->
			@startDaySlider.destroy()
			BaseView::cleanUp.apply( @, arguments )