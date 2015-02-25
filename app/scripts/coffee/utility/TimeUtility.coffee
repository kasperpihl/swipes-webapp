define ["momentjs"], (Moment)->
	class TimeUtility
		###
			Time based Helpers
		###
		getFormattedTime: (hour, minute, amPm) ->
			if minute < 10 then minute = "0" + minute
			return hour + ":" + minute if !amPm?
			if hour is 0 or hour is 24 then return "12:" + minute + " <small>AM</small>"
			else if hour <= 11 then return hour + ":" + minute + " <small>AM</small>"
			else if hour is 12 then return "12:" + minute + " <small>PM</small>"
			else return hour - 12 + ":" + minute + " <small>PM</small>"

		hourForSeconds: ( seconds ) ->
			return seconds / 3600
		minutesForSeconds: ( seconds ) ->
			return ( seconds % 3600 ) / 60
		daysToNextDayFromDay: (fromDay, toDay) ->
			return 0 if fromDay is toDay
			deltaDay = fromDay
			for number in [1...6]
				deltaDay++
				deltaDay = 0 if deltaDay > 6
				return number if deltaDay is toDay
		nextDayFromDay: (day) ->
			nextDay = day + 1
			nextDay = 0 if nextDay > 6
			nextDay
		isWeekend: (schedule) ->
			weekendStartDay = swipy.settings.get "SettingWeekendStart"
			weekendSecondDay = @nextDayFromDay(weekendStartDay)
			if schedule.getDay() is weekendStartDay or schedule.getDay() is weekendSecondDay then return yes
			else return no

		isWeekday: (schedule) ->
			return !@isWeekend schedule

		secondsSinceStartOfDay: ( date ) ->
			compareMoment = moment(date)
			startDayMomentDate = moment(date).startOf("day")
			parseInt(Math.abs(compareMoment.diff(startDayMomentDate) / 1000), 10)

		getMonFriSatSunFromDate: ( schedule ) ->
			if @isWeekday schedule
				@getNextWeekDay moment schedule
			else
				@getNextWeekendDay moment schedule

		getNextWeekDay: (date) ->
			# If date is friday, go to next monday, else go to tomorrow
			return date.add( "days", if date.day() is 5 then 3 else 1 ).toDate()

		getNextWeekendDay: (date) ->
			# If date is sunday, go to next saturday, else go to tomorrow (Which will always be sunday)
			return date.add( "days", if date.day() is 0 then 6 else 1 ).toDate()
		getNextDateFrom: ( date, repeatOption ) ->
			now = new Date().getTime()
			nextDate = date
			loop
				nextDate = moment nextDate
				switch repeatOption
					when "every day" then nextDate = nextDate.add( "days", 1 ).toDate()
					when "every week", "every month", "every year"
						type = repeatOption.replace( "every ", "" ) + "s"
						diff = 1
						nextDate = nextDate.add( type, Math.ceil diff ).toDate()
					when "mon-fri or sat+sun"
						nextDate = @getMonFriSatSunFromDate( nextDate.toDate() )
					# "never" + catch-all
					else return null
				break if nextDate.getTime() > now
			return nextDate