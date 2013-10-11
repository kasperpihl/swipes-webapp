define ["underscore", "momentjs"], (_, Moment) ->
	class ScheduleModel
		constructor: (@settings) ->
			@validateSettings()
			@data = @getData()
			
		validateSettings: ->

		getData: ->
			return [
				{ id: "later today", title: @getDynamicTime( "Later Today" ), disabled: no }
				{ id: "this evening", title: @getDynamicTime( "This Evening" ), disabled: no }
				{ id: "tomorrow", title: @getDynamicTime( "Tomorrow" ), disabled: no }
				{ id: "day after tomorrow", title: @getDynamicTime( "Day After Tomorrow" ), disabled: no }
				{ id: "this weekend", title: @getDynamicTime( "This Weekend" ), disabled: no }
				{ id: "next week", title: @getDynamicTime( "Next Week" ), disabled: no }
				{ id: "unspecified", title: @getDynamicTime( "Unspecified" ), disabled: no }
				{ id: "at location", title: @getDynamicTime( "At Location" ), disabled: yes }
				{ id: "pick a date", title: @getDynamicTime( "Pick A Date" ), disabled: no }
			]

		getDateFromScheduleOption: (option, now) ->
			if now
				newDate = moment now
			else
				newDate = moment()

			snoozes = swipy.settings.get "snoozes"
			switch option
				when "later today"
					newDate.hour( newDate.hour() + snoozes.laterTodayDelay.hours )
					newDate.minute( newDate.minute() + snoozes.laterTodayDelay.minutes )
				when "this evening"
					if newDate.hour() >= snoozes.weekday.evening.hour then newDate.add( "days", 1 )
					newDate.hour snoozes.weekday.evening.hour
					newDate.minute snoozes.weekday.evening.minute
					newDate = newDate.startOf "minute"
				when "tomorrow"
					newDate.add( "days", 1 )
					newDate.hour snoozes.weekday.morning.hour
					newDate.minute snoozes.weekday.morning.minute
					newDate = newDate.startOf "minute"
				when "day after tomorrow"
					newDate.add( "days", 2 )
					newDate.hour snoozes.weekday.morning.hour
					newDate.minute snoozes.weekday.morning.minute
					newDate = newDate.startOf "minute"
				when "this weekend"
					# If we're on weekend start date, fast-forward 7 days.
					if newDate.day() is snoozes.weekend.startDay.number
						newDate.add( "days", 7 )
					else
						newDate.day snoozes.weekend.startDay.name
					
					newDate.hour snoozes.weekend.morning.hour
					newDate.minute snoozes.weekend.morning.minute
					newDate = newDate.startOf "minute"
				when "next week"
					# If we're on week start date, fast-forward 7 days.
					if newDate.day() is snoozes.weekday.startDay.number
						newDate.add( "days", 7 )
					else
						newDate.day snoozes.weekday.start
					
					newDate.hour snoozes.weekday.morning.hour
					newDate.minute snoozes.weekday.morning.minute
					newDate = newDate.startOf "minute"
				else 
					# Catch any errors and return null, because then they aren't lost, just simply 
					# put in the 'unspecified' pile
					return null

			return newDate.toDate()
		getDynamicTime: (time, now) ->
			if not now then now = moment()

			switch time
				when "This Evening"
					return if now.hour() >= 18 then "Tomorrow Evening" else "This Evening"
				when "Day After Tomorrow"
					dayAfterTomorrow = moment( now ).add( "days", 2 )
					return dayAfterTomorrow.format "dddd"
				when "This Weekend"
					return if now.day() < 5 then "This Weekend" else "Next Weekend"
				else 
					return time

		toJSON: ->
			return { options: @data }
