define ["underscore", "backbone", "text!templates/calendar.html", "momentjs", "clndr"], (_, Backbone, CalendarTmpl) ->
	Backbone.View.extend
		tagName: "div"
		className: "calendar-wrap"
		initialize: ->
			_.bindAll( @, "handleClickDay", "handleMonthChanged", "handleYearChanged" )

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
				ready: => @selectDay @today
				daysOfTheWeek: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
			}
		createCalendar: ->
			@clndr = @$el.clndr @getCalendarOpts()
		getElementFromMoment: (moment) ->
			dateStr = moment.format "YYYY-MM-DD"
			# debugger
			@days.filter -> $(@).attr( "id" ).indexOf( dateStr ) isnt -1
		selectDay: (moment, element) ->
			@days = @$el.find ".day"

			@days.removeClass "selected"
			if not element? then element = @getElementFromMoment moment
			$( element ).addClass( "selected")
			@selectedDay = moment

			@$el.toggleClass( "displaying-curr-month", moment.isSame( @today, "month" ) )
		handleClickDay: (day) ->
			return false if $( day.element ).hasClass "past"
			@selectDay( day.date, day.element )
		handleYearChanged: (moment) ->
			console.log "Switched year to ", moment.year()
		handleMonthChanged: (moment) ->
			# Push selected day to new month.
			newDate = moment

			# Check if newMonth has as many days as current month
			# (I.e. switching from a 31 day month to a 29 day month)
			newDate.date @selectedDay.date()

			# Also check that we don't select a date prior to today
			if newDate.isBefore @today then newDate = @today

			console.log "Switched month to ", moment.month()
			@selectDay newDate
		render: ->
			@createCalendar()
			return @