define ["underscore", "js/view/modules/Calendar", "js/view/modules/TimeSlider", "text!templates/datepicker.html"], (_, CalendarView, TimeSliderView, DatePickerTmpl) ->
	Backbone.View.extend
		className: "picker"
		initialize: ->
			@setTemplate()
			@model = new Backbone.Model()
		setTemplate: ->
			@template = _.template DatePickerTmpl
		render: ->
			# Render base HTML
			@$el.html @template {}

			# Add Calendar view
			@timeSlider = new TimeSliderView { model: @model }
			@calendar = new CalendarView { model: @model }
			@$el.prepend( @timeSlider.el ).prepend( @calendar.el )

			@timeSlider.render()
			@calendar.render()

			return @