define ["underscore", "backbone", "text!templates/calendar.html", "momentjs", "clndr"], (_, Backbone, CalendarTmpl) ->
	Backbone.View.extend
		tagName: "div"
		className: "calendar-wrap"
		initialize: ->
			_.bindAll( @, "afterRender", "handleClickDay", "handleMonthChanged", "handleYearChanged" )

			@today = moment()
			@setTemplate()
			@render()
		setTemplate: ->
			@template = _.template CalendarTmpl
		getCalendarOpts: ->
			return {
				template: CalendarTmpl
				targets:
					nextButton: "next"
					previousButton: "previous"
					day: "day"
					empty: "empty"
				clickEvents:
					click: @handleClickDay
					onYearChange: @handleYearChanged
					onMonthChange: @handleMonthChanged
				doneRendering: @afterRender
				daysOfTheWeek: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
			}
		createCalendar: ->
			@clndr = this.$el.clndr @getCalendarOpts()
		getElementFromMoment: (moment) ->
			dateStr = moment.format "YYYY-MM-DD"
			@days.filter -> $(@).attr( "id" ).indexOf( dateStr ) isnt -1
		selectDay: (moment, element) ->
			@days.removeClass "selected"
			el = element or @getElementFromMoment moment
			$(el).addClass( "selected")
		handleClickDay: (day) ->
			@selectDay( day.date, day.element )
		handleYearChanged: (moment) ->
			console.log "Switched year to ", moment.year()
		handleMonthChanged: (moment) ->
			console.log "Switched month to ", moment.month()
		render: ->
			@createCalendar()
			return @
		afterRender: ->
			@days = @$el.find ".day"
			@selectDay @today