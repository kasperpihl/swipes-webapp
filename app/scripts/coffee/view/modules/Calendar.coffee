define ["underscore", "backbone", "text!templates/calendar.html", "momentjs", "clndr"], (_, Backbone, CalendarTmpl) ->
	Parse.View.extend
		tagName: "div"
		className: "calendar-wrap"
		initialize: ->
			_.bindAll( @, "handleClickDay", "handleMonthChanged" )

			@listenTo( @model, "change:date", @renderDate )
			@listenTo( @model, "change:time", @renderTime )

			@today = moment()
		getCalendarOpts: ->
			return {
				template: CalendarTmpl
				targets:
					nextButton: "next"
					previousButton: "previous"
					day: "day"
				clickEvents:
					click: @handleClickDay
					onMonthChange: @handleMonthChanged
				weekOffset: swipy.settings.get( "snoozes" ).weekday.startDay.number
				doneRendering: @afterRender
				ready: => @selectDay @today
				daysOfTheWeek: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
			}
		createCalendar: ->
			@clndr = @$el.clndr @getCalendarOpts()
		getElementFromMoment: (moment) ->
			dateStr = moment.format "YYYY-MM-DD"
			@days.filter -> $(@).attr( "class" ).indexOf( dateStr ) isnt -1
		getTimeObj: (moment) ->
			snoozes = swipy.settings.get "snoozes"
			day = @selectedDay.day()

					  # sunday    # Saturday
			if day is 0 or day is 6
				hour: snoozes.weekend.morning.hour
				minute: snoozes.weekend.morning.minute
			else
				hour: snoozes.weekday.morning.hour
				minute: snoozes.weekday.morning.minute
		getFormattedTime: (hour, minute) ->
			if minute < 10 then minute = "0" + minute

			if hour is 0 or hour is 24 then return "12:" + minute + " AM"
			else if hour <= 11 then return hour + ":" + minute + " AM"
			else if hour is 12 then return "12:" + minute + " PM"
			else return hour - 12 + ":" + minute + " PM"
		selectDay: (moment, element) ->
			@days = @$el.find ".day"

			@days.removeClass "selected"
			if not element? then element = @getElementFromMoment moment
			$( element ).addClass "selected"
			@selectedDay = moment

			# This class disables the "Previous month" button, if we're at the current month
			@$el.toggleClass( "displaying-curr-month", moment.isSame( @today, "month" ) )

			@model.unset( "date", { silent: yes } )
			@model.set( "date", @selectedDay )

			if @model.get "userManuallySetTime"
				@renderTime()
			else
				@model.set( "time", @getTimeObj @selectedDay )
				@model.set( "timeEditedBy", "calendar" )
		handleClickDay: (day) ->
			return false if $( day.element ).hasClass "past"
			@selectDay( day.date, day.element )

			# Auto switch to next/prev month if adjecent month is clicked
			$el = $ day.element
			if $el.hasClass "adjacent-month"
				if $el.hasClass "last-month" then @clndr.back()
				else @clndr.forward()
		handleMonthChanged: (moment) ->
			# Push selected day to new month.
			newDate = moment


			# Check if newMonth has as many days as current month
			# (I.e. switching from a 31 day month to a 29 day month)
			# Moment.js does this automatically.
			oldDate = @selectedDay.date()
			maxDate = newDate.daysInMonth()
			newDate.date Math.min( oldDate, maxDate )

			# Also check that we don't select a date prior to today
			if newDate.isBefore @today then newDate = @today

			@selectDay newDate
		render: ->
			@createCalendar()
			return @
		renderDate: ->
			@$el.find(".month .selected-date").text @selectedDay.format("MMM Do")
		renderTime: ->
			time = @model.get "time"
			@$el.find(".month time").text @getFormattedTime( time.hour, time.minute )
		remove: ->
			@undelegateEvents()
			@stopListening()
			@$el.remove()