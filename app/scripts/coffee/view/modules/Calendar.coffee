define ["underscore", "backbone", "text!templates/calendar.html", "clndr"], (_, Backbone, CalendarTmpl) ->
	Backbone.View.extend
		tagName: "div"
		className: "calendar-wrap"
		initialize: ->
			@setTemplate()
			@render()
		setTemplate: ->
			@template = _.template CalendarTmpl
		render: ->
			@$el.html @template {}
			return @
