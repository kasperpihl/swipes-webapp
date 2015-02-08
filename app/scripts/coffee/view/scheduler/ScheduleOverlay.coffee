define ["underscore", "backbone", "js/view/Overlay", "text!templates/schedule-overlay.html"], (_, Backbone, Overlay, ScheduleOverlayTmpl) ->
	Overlay.extend
		className: 'overlay scheduler'
		events:
			"click .grid > a:not(.disabled)": "selectOption"
			"click .overlay-bg": "hide"
			"click .date-picker .back": "hideDatePicker"
			"click .date-picker .save": "selectOption"
		initialize: ->
			Overlay::initialize.apply( @, arguments )

			@showClassName = "scheduler-open"
			@hideClassName = "hide-scheduler"
		bindEvents: ->
			_.bindAll( @, "handleResize", "keyUpHandling" )
			$(window).on( "resize", @handleResize )
			#$(document).on( 'keyup.overlay-content', @handleKeyUp )
				
		keyUpHandling: (e) ->
			console.log e.keyCode
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
			if target.hasClass( "save" ) and @datePicker?
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
			target = $ e.currentTarget
			@selectOptionFromTarget(target)
			
		hide: (cancelled = yes) ->
			if cancelled and @currentTasks?
				Backbone.trigger( "scheduler-cancelled", @currentTasks )
			Overlay::hide.apply( @, arguments )
		showDatePicker: ->
			if not @datePicker? then require ["js/view/modules/DatePicker"], (DatePicker) =>
				@datePicker = new DatePicker()

				@$el.find( ".overlay-content" ).append @datePicker.el
				@$el.addClass "show-datepicker"

				@datePicker.render()
			else
				@$el.addClass "show-datepicker"

			setTimeout =>
					@handleResize()
				, 100
		hideDatePicker: ->
			@$el.removeClass "show-datepicker"
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

