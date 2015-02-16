define ["underscore", "momentjs", "js/utility/TimeUtility"], (_, Moment, TimeUtility) ->
	class ScheduleModel
		constructor: (@settings) ->
			@timeUtil = new TimeUtility()
			@validateSettings()
			@data = @getData()
			_.bindAll( @, "getDynamicTime" )
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
			nowDate = newDate.toDate()
			snoozes = swipy.settings.get "snoozes"
			todayIsWeekend = @timeUtil.isWeekend( nowDate )
			currentSecondsInDay = @timeUtil.secondsSinceStartOfDay( newDate )
			weekStartTime = swipy.settings.get "SettingWeekStartTime"
			weekendStartTime = swipy.settings.get "SettingWeekendStartTime"
			switch option
				when "later today"
					setting = swipy.settings.get("SettingLaterToday")
					newDate.add( setting , "seconds" )
				when "this evening"
					setting = swipy.settings.get("SettingEveningStartTime")
					if currentSecondsInDay > setting then newDate.add("days", 1 )
					newDate.startOf("day").add( setting, "seconds" )
				when "tomorrow"
					targetStartTime = weekStartTime
					dayIsWeekend = todayIsWeekend
					if todayIsWeekend and currentSecondsInDay > weekendStartTime or !todayIsWeekend and currentSecondsInDay > weekStartTime
						newDate.add( "days", 1 )
						dayIsWeekend = @timeUtil.isWeekend( newDate.toDate() )
					targetStartTime = weekendStartTime if dayIsWeekend
					newDate.startOf("day").add( "seconds", targetStartTime )

				when "day after tomorrow"
					newDate.add( "days", 1 )
					dayIsWeekend = @timeUtil.isWeekend( newDate.toDate() )
					targetStartTime = weekStartTime
					if dayIsWeekend and currentSecondsInDay > weekendStartTime or !dayIsWeekend and currentSecondsInDay > weekStartTime
						newDate.add( "days", 1 )
						dayIsWeekend = @timeUtil.isWeekend( newDate.toDate() )
					targetStartTime = weekendStartTime if dayIsWeekend

					newDate.startOf("day").add( "seconds", targetStartTime)

				when "this weekend"
					weekendStartDay = swipy.settings.get "SettingWeekendStart"
					# If we're on weekend start date, fast-forward 7 days.
					numberOfDaysToNextWeekend = @timeUtil.daysToNextDayFromDay(newDate.day(), weekendStartDay)
					if numberOfDaysToNextWeekend
						newDate.add( "days", numberOfDaysToNextWeekend )
					else if currentSecondsInDay > weekendStartTime
						newDate.add( "days", 7 )
					newDate.startOf("day").add("seconds", weekendStartTime)

				when "next week"
					weekStartDay = swipy.settings.get "SettingWeekStart"
					numberOfDaysToNextWeek = @timeUtil.daysToNextDayFromDay( newDate.day(), weekStartDay )
					if numberOfDaysToNextWeek
						newDate.add( "days", numberOfDaysToNextWeekend )
					else if currentSecondsInDay > weekStartTime
						newDate.add( "days", 7 )

					# Now, if dayNumber is the same as the snoozes weekday start day, we don't need to do anything else
					# Else: We need to change the day number to the default week start day
					
					newDate.startOf("day").add("seconds",weekStartTime)
				else
					# Catch any errors and return null, because then they aren't lost, just simply
					# put in the 'unspecified' pile
					return null

			return newDate.toDate()
		getDynamicTime: (time, now) ->
			if not now then now = moment()

			switch time
				when "This Evening"
					setting = swipy.settings.get("SettingEveningStartTime")
					currentSecondsInDay = @timeUtil.secondsSinceStartOfDay( now )
					return if currentSecondsInDay >= setting then "Tomorrow Eve" else "This Evening"
				when "Day After Tomorrow"
					dayAfterTomorrow = moment( now ).add( "days", 2 )
					return dayAfterTomorrow.format "dddd"
				when "This Weekend"
					return if now.day() < 5 then "This Weekend" else "Next Weekend"
				else
					return time

		toJSON: ->
			return { options: @data }
