define ["underscore", "backbone", "view/Overlay", "text!templates/schedule-overlay.html"], (_, Backbone, Overlay, ScheduleOverlayTmpl) ->
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
			_.bindAll( @, "handleResize" )
			$(window).on( "resize", @handleResize )
		setTemplate: ->
			@template = _.template ScheduleOverlayTmpl
		render: ->
			if @template
				html = @template @model.toJSON()
				@$el.html html

			return @
		afterShow: ->
			@handleResize()
		selectOption: (e) ->
			target = $ e.currentTarget

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
		hide: (cancelled = yes) ->
			if cancelled and @currentTasks?
				Backbone.trigger( "scheduler-cancelled", @currentTasks )

			Overlay::hide.apply( @, arguments )
		showDatePicker: ->
			if not @datePicker? then require ["view/modules/DatePicker"], (DatePicker) =>
				@datePicker = new DatePicker()

				@$el.find( ".overlay-content" ).append @datePicker.el
				@$el.addClass "show-datepicker"

				@datePicker.render()
			else
				@$el.addClass "show-datepicker"
		hideDatePicker: ->
			@$el.removeClass "show-datepicker"
		handleResize: ->
			return unless @shown

			content = @$el.find ".overlay-content"
			offset = ( window.innerHeight / 2 ) - ( content.height() / 2 )
			content.css( "margin-top", offset )
		cleanUp: ->
			$(window).off( "resize", @handleResize )
			@datePicker.remove()

			# Same as super() in real OOP programming
			Overlay::cleanUp.apply( @, arguments )

