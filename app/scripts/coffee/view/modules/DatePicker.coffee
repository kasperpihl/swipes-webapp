define ["underscore", "backbone", "view/modules/Calendar", "text!templates/datepicker.html"], (_, Backbone, CalendarView, DatePickerTmpl) ->
	Backbone.View.extend
		className: "date-picker"
		initialize: ->
			@setTemplate()
			@render()
		setTemplate: ->
			@template = _.template DatePickerTmpl
		render: ->
			console.log @template {}
			@$el.html @template {}
			@calendar = new CalendarView()
			@$el.find( ".content" ).append @calendar.el
			return @