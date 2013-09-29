define ["underscore", "momentjs"], (_, Moment) ->
	class ScheduleModel
		rules: 
			evening: 18
			laterTodayDelay: 3
			weekday: { start: "Monday", morning: 9 }
			weekend: { start: "Saturday", morning: 10 }
		
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

			# Check settings for 'this evening' setting, but for now just use 18:00
			switch option
				when "later today"
					newDate.hour( newDate.hour() + @rules.laterTodayDelay )
				when "this evening"
					if newDate.hour() >= @rules.evening then newDate.add( "days", 1 )
					newDate.hour @rules.evening
				when "tomorrow"
					newDate.add( "days", 1 )
					newDate.hour @rules.weekday.morning
				when "day after tomorrow"
					newDate.add( "days", 2 )
					newDate.hour @rules.weekday.morning
				when "this weekend"
					newDate.day @rules.weekend.start
					newDate.hour @rules.weekend.morning
				when "next week"
					newDate.day @rules.weekday.start
					newDate.hour @rules.weekday.morning
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
