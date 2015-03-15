define ["gsap-draggable", "slider-control", "text!templates/sidemenu/settings/sidemenu-settings-snoozes.html", "js/utility/TimeUtility"], (Draggable, SliderControl, Tmpl, TimeUtility) ->
	Backbone.View.extend
		className: "snoozes"
		events:
			"click button": "toggleSection"
			"click .week-start-day .day-picker li": "toggleWeekDay"
			"click .weekend-start-day .day-picker li": "toggleWeekendDay"
		initialize: ->
			Backbone.View::initialize.apply( @, arguments )
			@setTemplate()
			@timeUtil = new TimeUtility()
			_.bindAll( @, "updateValue" )
			@render()
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
		getSliderVal: (sliderId) ->
			###
			NSInteger hours = eveningStartTime.integerValue/D_HOUR;
			NSInteger minutes = (eveningStartTime.integerValue % D_HOUR) / D_MINUTE;
			###
			switch sliderId
				when "start-day"
					setting = swipy.settings.get "SettingWeekStartTime"
				when "start-evening"
					setting = swipy.settings.get "SettingEveningStartTime"
				when "start-weekend"
					setting = swipy.settings.get "SettingWeekendStartTime"
				when "delay"
					setting = swipy.settings.get "SettingLaterToday"
			
			hours = @timeUtil.hourForSeconds setting
			minutes = @timeUtil.minutesForSeconds setting
			@getFloatFromTime( hours, minutes )
			
		updateValue: (sliderId, updateModel = no) ->
			amPm = @timeUtil.isAmPm()
			switch sliderId
				when "start-day"
					setting = "SettingWeekStartTime"
					time = @getTimeFromFloat @startDaySlider.value
					@$el.find(".day button").text @timeUtil.getFormattedTime( time.hour, time.minute, amPm )
				when "start-evening"
					setting = "SettingEveningStartTime"
					time = @getTimeFromFloat @startEveSlider.value
					@$el.find(".evening button").text @timeUtil.getFormattedTime( time.hour, time.minute, amPm )
				when "start-weekend"
					setting = "SettingWeekendStartTime"
					time = @getTimeFromFloat @startWeekendSlider.value
					@$el.find(".weekends button").text @timeUtil.getFormattedTime( time.hour, time.minute, amPm )
				when "delay"
					setting = "SettingLaterToday"
					time = @getTimeFromFloat @delaySlider.value
					@$el.find(".later-today button").text "+#{ @timeUtil.getFormattedTime( time.hour, time.minute, no ) }h"

			if updateModel and setting?
				newVal = @timeUtil.secondsSinceStartOfDay time
				swipy.settings.set(setting, newVal)
		setTemplate: ->
			@template = _.template Tmpl
		render: ->
			settings = swipy.settings.model.toJSON()
			@$el.html @template { settings: settings }
			weekFindString = ".week-start-day .day-picker li[data-num="+swipy.settings.get("SettingWeekStart")+"]"
			weekendFindString = ".weekend-start-day .day-picker li[data-num="+swipy.settings.get("SettingWeekendStart")+"]"
			@$el.find(weekFindString).addClass("selected")
			@$el.find(weekendFindString).addClass("selected")
		toggleSection: (e) ->
			$parent = $(e.currentTarget.parentNode.parentNode).toggleClass "toggled"

			if $parent.hasClass "toggled"
				if $parent.hasClass "day"
					el = @el.querySelector ".day .range-slider"
					opts =
						onDrag: => @updateValue( "start-day", arguments... )
						onDragEnd: => @updateValue( "start-day", yes, arguments... )
						steps: ( 24 * 4 ) + 1

					@startDaySlider.destroy() if @startDaySlider?
					@startDaySlider = new SliderControl( el, opts, @getSliderVal "start-day" )

				else if $parent.hasClass "evening"
					el = @el.querySelector ".evening .range-slider"
					opts =
						onDrag: => @updateValue( "start-evening", arguments... )
						onDragEnd: => @updateValue( "start-evening", yes, arguments... )
						steps: ( 24 * 4 ) + 1

					@startEveSlider.destroy() if @startEveSlider?
					@startEveSlider = new SliderControl( el, opts, @getSliderVal "start-evening" )

				else if $parent.hasClass "weekends"
					el = @el.querySelector ".weekends .range-slider"
					opts =
						onDrag: => @updateValue( "start-weekend", arguments... )
						onDragEnd: => @updateValue( "start-weekend", yes, arguments... )
						steps: ( 24 * 4 ) + 1

					@startWeekendSlider.destroy() if @startWeekendSlider?
					@startWeekendSlider = new SliderControl( el, opts, @getSliderVal "start-weekend" )

				else if $parent.hasClass "later-today"
					el = @el.querySelector ".later-today .range-slider"
					opts =
						onDrag: => @updateValue( "delay", arguments... )
						onDragEnd: => @updateValue( "delay", yes, arguments... )
						steps: ( 24 * 4 ) + 1

					@delaySlider.destroy() if @delaySlider?
					@delaySlider = new SliderControl( el, opts, @getSliderVal "delay" )
		toggleWeekendDay: (e) ->
			$(".weekend-start-day .day-picker li").removeClass "selected"
			$(e.currentTarget).addClass "selected"
			dayName = e.currentTarget.getAttribute "data-name"
			dayNum = e.currentTarget.getAttribute "data-num"

			@$el.find( ".weekend-start-day button" ).text dayName

			swipy.settings.set( "SettingWeekendStart", parseInt(dayNum, 10) )
		toggleWeekDay: (e) ->
			$(".week-start-day .day-picker li").removeClass "selected"
			$(e.currentTarget).addClass "selected"
			dayName = e.currentTarget.getAttribute "data-name"
			dayNum = e.currentTarget.getAttribute "data-num"

			@$el.find( ".week-start-day button" ).text dayName

			swipy.settings.set( "SettingWeekStart", parseInt(dayNum, 10) )
		destroy: ->
			@cleanUp()
		cleanUp: ->
			@startDaySlider?.destroy()
			@startEveSlider?.destroy()
			@startWeekendSlider?.destroy()
			@delaySlider?.destroy()