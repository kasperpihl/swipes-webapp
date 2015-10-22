define ["underscore",
		"js/view/modal/ModalView"
		"text!templates/schedule-overlay.html", 
		"js/view/modules/TimeSlider", 
		"js/utility/TimeUtility", 
		"jquery-hammerjs", 
		"momentjs"], (_, ModalView, ScheduleOverlayTmpl, TimeSliderView, TimeUtility) ->
	ModalView.extend
		className: 'scheduler'
		events:
			"click .grid > a:not(.disabled)": "selectOption"
			"click .date-picker .back-button": "hideDatePicker"
			"click .time-picker .back-button" :"hideTimePicker"
			"click .date-picker .save-button": "selectOption"
			"click .time-picker .done-button": "selectedOptionFromTimePicker"
		initialize: ->
			@setTemplate()
			@bindEvents()
			@timeUtil = new TimeUtility()
			@activeMenu = "grid"
			@enableTouchListners()
		enableTouchListners: ->
			@$el.hammer( @getHammerOpts() ).on( "press", ".snooze-options .grid > a", @longPress )
		disableTouchListeners: ->
			@$el.hammer().off( "press", @longPress )
		longPress:(e) ->
			target = $ e.currentTarget
			@selectOptionFromTarget(target, true)
		getHammerOpts: ->
			# Options at: https://github.com/EightMedia/hammer.js/wiki/Getting-Started
			{
				drag: off
				swipe: off
				tap: off
				transform: off
				# hold_threshold: 50
				prevent_default: yes
				hold_timeout: if Modernizr.touch then 400 else 400
				domEvents:true
			}
		bindEvents: ->
			_.bindAll( @, "keyUpHandling", "longPress" )

		keyUpHandling: (e) ->
			if e.keyCode > 48 and e.keyCode < 58 and @$el.html
				#if @$el.hasClass "show-datepicker"
				elNumber = parseInt( e.keyCode - 48, 10 )
				pressedKey = $('.overlay .grid > a:nth-child(' + elNumber + ')')
				@selectOptionFromTarget(pressedKey, true)
				e.stopPropagation()
		setTemplate: ->
			@template = _.template ScheduleOverlayTmpl
		render: ->
			if @template
				html = @template @model.toJSON()
				@$el.html html

			return @
		callbackAndClose: (result) ->
			@callback?(result)
			@callback = null
			@dismissModal() if @shown?
		didCloseModal: ->
			@callbackAndClose(false)
		selectOptionFromTarget: (target, longPress) ->
			if target.hasClass( "done-button" )
				if @activeDate? and @timePickerSlider?
					date = moment(@activeDate)
					time = @timePickerSlider.model.get "time"
					date.millisecond 0
					date.second 0
					date.hour time.hour
					date.minute time.minute
					@activeDate = null
					option = date
					@hideTimePicker()

			else if target.hasClass( "save-button" ) and @datePicker?
				locMoment = @datePicker.calendar.selectedDay
				time = @datePicker.model.get "time"

				locMoment.millisecond 0
				locMoment.second 0
				locMoment.hour time.hour
				locMoment.minute time.minute

				option = locMoment
				@hideDatePicker()
			else
				option = target.attr "data-option"
				if option is "pick a date"
					@showDatePicker()
					return
				if longPress? and longPress
					switch option
						when "later today", "this evening", "tomorrow", "day after tomorrow", "this weekend", "next week"
							@showTimePicker(option)
							@didLongPress = true
							return
			@callbackAndClose(option)
		getDayWithoutTime: (day) ->
			fullStr = day.calendar()
			timeIndex = fullStr.indexOf( " at " )

			# Date is within the next week, so just sat the day name — calendar() returns something like "Tuesday at 3:30pm",
			# and we only want "Tuesday", so use this little RegEx to select everything before the first space.
			if timeIndex isnt -1
				return fullStr.slice( 0, timeIndex )
			else
				return fullStr
		getTitleStringForDate:(schedule) ->
			now = moment()
			parsedDate = moment schedule
			dayDiff =  Math.abs parsedDate.diff( now, "days" )

			# If difference is more than 1 week, we want different formatting
			if dayDiff >= 6
				# If it's next year, add year suffix
				if parsedDate.year() > now.year() then result = parsedDate.format "MMM Do 'YY"
				else result = parsedDate.format "MMM Do"
			else
				result = @getDayWithoutTime parsedDate

			result
		selectedOptionFromTimePicker: (e) ->
			target = $ e.currentTarget
			@selectOptionFromTarget(target, false)
		selectOption: (e) ->
			return if @didLongPress? and @didLongPress
#			if $(e.currentTarget).attr("data-option") is "pick a date"
#				return @showDatePicker()
			target = $ e.currentTarget
			@selectOptionFromTarget(target, true)

		setActiveMenu: (className) ->
			$(".overlay-content .snooze-options > nav").removeClass("active")
			$(".overlay-content .snooze-options > nav."+className).addClass("active")
			@activeMenu = className
		showDatePicker: ->
			if not @datePicker? then require ["js/view/modules/DatePicker"], (DatePicker) =>
				@datePicker = new DatePicker()

				@$el.find( ".overlay-content .snooze-options .date-picker" ).html @datePicker.el
				#@$el.addClass "show-datepicker"
				@datePicker.render()
				@alignModal()
			else
				#@$el.addClass "show-datepicker"
			
			@setActiveMenu("date-picker")
		changedTimeOnPicker: (model, value) ->
			amPm = @timeUtil.isAmPm()
			@$el.find(".time-label").html(@timeUtil.getFormattedTime(value.hour, value.minute, amPm, true))
		showTimePicker: (option) ->
			if not @timePickerSlider?
				model = new Backbone.Model()
				model.on("change:time", @changedTimeOnPicker, @)
				@timePickerSlider = new TimeSliderView { model: model }
				@$el.find( ".overlay-content .snooze-options .time-picker .time-slider" ).html @timePickerSlider.el
				@timePickerSlider.render()

			@activeDate = @model.getDateFromScheduleOption(option)
			momentDate = moment @activeDate

			@timePickerSlider.model.set("time", { hour: momentDate.hour(), minute: momentDate.minute()})
			@$el.find( ".overlay-content .snooze-options .time-picker .day-label" ).html @getTitleStringForDate(@activeDate)
			@setActiveMenu("time-picker")
		hideDatePicker: ->
			@didLongPress = false
			@setActiveMenu( "grid" )
		hideTimePicker: ->
			@didLongPress = false
			@setActiveMenu( "grid")

		cleanUp: ->
			@datePicker?.remove()
			@disableTouchListeners()

