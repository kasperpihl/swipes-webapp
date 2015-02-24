define ["underscore", "js/view/Overlay", "text!templates/schedule-overlay.html", "js/view/modules/TimeSlider"], (_, Overlay, ScheduleOverlayTmpl, TimeSliderView) ->
	Overlay.extend
		className: 'overlay scheduler'
		events:
			"click .grid > a:not(.disabled)": "selectOption"
			"click .overlay-bg": "hide"
			"click .date-picker .back-button": "hideDatePicker"
			"click .time-picker .back-button" :"hideTimePicker"
			"click .date-picker .save-button": "selectOption"
		initialize: ->
			Overlay::initialize.apply( @, arguments )

			@showClassName = "scheduler-open"
			@hideClassName = "hide-scheduler"
			@activeMenu = "grid"
		bindEvents: ->
			_.bindAll( @, "handleResize", "keyUpHandling" )
			$(window).on( "resize", @handleResize )
			#$(document).on( 'keyup.overlay-content', @handleKeyUp )
				
		keyUpHandling: (e) ->
			if e.keyCode > 48 and e.keyCode < 58 and @$el.html
				#if @$el.hasClass "show-datepicker"
				elNumber = parseInt( e.keyCode - 48, 10 )
				pressedKey = $('.overlay .grid > a:nth-child(' + elNumber + ')')
				@selectOptionFromTarget(pressedKey)
				e.stopPropagation()
		setTemplate: ->
			@template = _.template ScheduleOverlayTmpl
		render: ->
			if @template
				html = @template @model.toJSON()
				@$el.html html

			return @
		afterShow: ->
			@handleResize()
			swipy.shortcuts.pushDelegate( @ )
		afterHide: ->
			swipy.shortcuts.popDelegate()
		selectOptionFromTarget: (target) ->
			if target.hasClass( "save-button" ) and @datePicker?
				moment = @datePicker.calendar.selectedDay
				time = @datePicker.model.get "time"

				moment.millisecond 0
				moment.second 0
				moment.hour time.hour
				moment.minute time.minute

				option = moment
				@hideDatePicker()
			else
				option = target.attr "data-option"
			Backbone.trigger( "pick-schedule-option", option )
		selectOption: (e) ->
			if $(e.currentTarget).attr("data-option") is "pick a date"
				@showDatePicker()
			else
				@showTimePicker()
			return
			target = $ e.currentTarget
			@selectOptionFromTarget(target)
			
		hide: (cancelled = yes) ->
			if cancelled and @currentTasks?
				Backbone.trigger( "scheduler-cancelled", @currentTasks )
			Overlay::hide.apply( @, arguments )
		setActiveMenu: (className) ->
			$(".overlay-content .snooze-options > nav").removeClass("active")
			$(".overlay-content .snooze-options > nav."+className).addClass("active")
			@activeMenu = className
			setTimeout =>
				@handleResize()
			, 100
		showDatePicker: ->
			if not @datePicker? then require ["js/view/modules/DatePicker"], (DatePicker) =>
				@datePicker = new DatePicker()

				@$el.find( ".overlay-content .snooze-options .date-picker" ).html @datePicker.el
				#@$el.addClass "show-datepicker"
				@datePicker.render()
			else
				#@$el.addClass "show-datepicker"
			
			@setActiveMenu("date-picker")
		showTimePicker: ->
			if not @timePickerSlider?
				model = new Backbone.Model()
				@timePickerSlider = new TimeSliderView { model: model }
				@$el.find( ".overlay-content .snooze-options .time-picker .time-slider" ).html @timePickerSlider.el
				@timePickerSlider.render()
				@timePickerSlider.model.set("time", { hour: 9, minute: 0})
			@setActiveMenu("time-picker")
		hideDatePicker: ->
			@setActiveMenu( "grid" )
		hideTimePicker: ->
			@setActiveMenu( "grid")
		handleResize: ->
			return unless @shown

			content = @$el.find ".overlay-content"
			offset = ( window.innerHeight / 2 ) - ( content.height() / 2 )
			content.css( "margin", offset + "px auto 0" )
			content.css( "width", content.height() )
		cleanUp: ->
			$(window).off( "resize", @handleResize )
			@datePicker.remove()
			#$(document).off(".overlay-content")
			# Same as super() in real OOP programming
			Overlay::cleanUp.apply( @, arguments )

