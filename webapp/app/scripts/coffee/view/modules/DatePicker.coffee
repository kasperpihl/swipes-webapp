define ["underscore", "backbone", "js/view/modules/Calendar", "js/view/modules/TimeSlider", "text!templates/datepicker.html"], (_, Backbone, CalendarView, TimeSliderView, DatePickerTmpl) ->
	Parse.View.extend
		className: "date-picker"
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
			@$el.find( ".content" ).append( @calendar.el ).append( @timeSlider.el )

			@timeSlider.render()
			@calendar.render()

			return @