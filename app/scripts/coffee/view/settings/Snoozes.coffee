define ["view/settings/BaseSubview", "gsap-draggable", "slider-control", "text!templates/settings-snoozes.html"], (BaseView, Draggable, SliderControl, Tmpl) ->
	BaseView.extend
		className: "snoozes"
		events:
			"click button": "toggleSection"
			"click .day-picker li": "toggleDay"
		initialize: ->
			BaseView::initialize.apply( @, arguments )
			_.bindAll( @, "updateValue" )
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
		getFormattedTime: (hour, minute, addAmPm = yes) ->
			if minute < 10 then minute = "0" + minute

			if addAmPm
				if hour is 0 or hour is 24 then return "12:" + minute + " AM"
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
				when "start-evening"
					@getFloatFromTime( snoozes.weekday.evening.hour, snoozes.weekday.evening.minute )
				when "start-weekend"
					@getFloatFromTime( snoozes.weekend.morning.hour, snoozes.weekend.morning.minute )
				when "delay"
					@getFloatFromTime( snoozes.laterTodayDelay.hours, snoozes.laterTodayDelay.minutes )
		updateValue: (sliderId, updateModel = no) ->
			snoozes = swipy.settings.get "snoozes"

			switch sliderId
				when "start-day"
					time = @getTimeFromFloat @startDaySlider.value
					snoozes.weekday.morning = time
					@$el.find(".day button").text @getFormattedTime( time.hour, time.minute )
				when "start-evening"
					time = @getTimeFromFloat @startEveSlider.value
					snoozes.weekday.evening = time
					@$el.find(".evening button").text @getFormattedTime( time.hour, time.minute )
				when "start-weekend"
					time = @getTimeFromFloat @startWeekendSlider.value
					snoozes.weekend.morning = time
					@$el.find(".weekends button").text @getFormattedTime( time.hour, time.minute )
				when "delay"
					time = @getTimeFromFloat @delaySlider.value
					snoozes.laterTodayDelay.hours = time.hour
					snoozes.laterTodayDelay.minutes = time.minute
					@$el.find(".later-today button").text "+#{ @getFormattedTime( time.hour, time.minute, no ) }h"

			if updateModel
				swipy.settings.unset( "snoozes", { silent: yes } )
				swipy.settings.set( "snoozes", snoozes )
		setTemplate: ->
			@template = _.template Tmpl
		render: ->
			@$el.html @template { snoozes: swipy.settings.get "snoozes" }
			@transitionIn()
		toggleSection: (e) ->
			$parent = $(e.currentTarget.parentNode.parentNode).toggleClass "toggled"

			if $parent.hasClass "toggled"
				if $parent.hasClass "day"
					el = @el.querySelector ".day .range-slider"
					opts =
						onDrag: => @updateValue( "start-day", arguments... )
						onDragEnd: => @updateValue( "start-day", yes, arguments... )

					@startDaySlider.destroy() if @startDaySlider?
					@startDaySlider = new SliderControl( el, opts, @getSliderVal "start-day" )

				else if $parent.hasClass "evening"
					el = @el.querySelector ".evening .range-slider"
					opts =
						onDrag: => @updateValue( "start-evening", arguments... )
						onDragEnd: => @updateValue( "start-evening", yes, arguments... )

					@startEveSlider.destroy() if @startEveSlider?
					@startEveSlider = new SliderControl( el, opts, @getSliderVal "start-evening" )

				else if $parent.hasClass "weekends"
					el = @el.querySelector ".weekends .range-slider"
					opts =
						onDrag: => @updateValue( "start-weekend", arguments... )
						onDragEnd: => @updateValue( "start-weekend", yes, arguments... )

					@startWeekendSlider.destroy() if @startWeekendSlider?
					@startWeekendSlider = new SliderControl( el, opts, @getSliderVal "start-weekend" )

				else if $parent.hasClass "later-today"
					el = @el.querySelector ".later-today .range-slider"
					opts =
						onDrag: => @updateValue( "delay", arguments... )
						onDragEnd: => @updateValue( "delay", yes, arguments... )

					@delaySlider.destroy() if @delaySlider?
					@delaySlider = new SliderControl( el, opts, @getSliderVal "delay" )
		toggleDay: (e) ->
			$(".day-picker li").removeClass "selected"
			$(e.currentTarget).addClass "selected"
			dayName = e.currentTarget.getAttribute "data-name"
			dayNum = e.currentTarget.getAttribute "data-num"

			@$el.find( ".week-start-day button" ).text dayName

			snoozes = swipy.settings.get "snoozes"
			snoozes.weekday.startDay = { name: dayName, number: dayNum }
			swipy.settings.unset( "snoozes", { silent: yes } )
			swipy.settings.set( "snoozes", snoozes )
		cleanUp: ->
			@startDaySlider?.destroy()
			@startEveSlider?.destroy()
			@startWeekendSlider?.destroy()
			@delaySlider?.destroy()
			BaseView::cleanUp.apply( @, arguments )