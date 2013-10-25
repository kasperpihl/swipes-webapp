define ["underscore", "backbone", "view/modules/Calendar", "text!templates/datepicker.html"], (_, Backbone, CalendarView, DatePickerTmpl) ->
	Backbone.View.extend
		className: "date-picker"
		initialize: ->
			@setTemplate()
			@render()
		setTemplate: ->
			@template = _.template DatePickerTmpl
		render: ->
			# Render base HTML
			@$el.html @template {}

			# Add Calendar view
			@calendar = new CalendarView()
			@$el.find( ".content" ).append @calendar.el
			@calendar.render()

			return @