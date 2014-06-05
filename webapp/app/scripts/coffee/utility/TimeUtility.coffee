define ->
	class TimeUtility
		###
			Time based Helpers
		###
		isWeekend: (schedule) ->
			if schedule.getDay() is 0 or schedule.getDay() is 6 then return yes
			else return no

		isWeekday: (schedule) ->
			return !@isWeekend schedule

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
			console.log repeatOption
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