define ["backbone", "momentjs"], (Backbone, Moment) ->
	Backbone.Model.extend
		defaults: 
			title: ""
			order: 0
			schedule: new Date()
			completionDate: null
			repeatOption: "never"
			repeatDate: null
			repeatCount: 0
			tags: null
			notes: ""
			deleted: no
		initialize: ->
			@setScheduleString()
			@on "change:schedule", @setScheduleString
		setScheduleString: ->
			schedule = @get "schedule"
			if !schedule then return @set( "scheduleString", undefined )

			now = moment()
			parsedDate = moment schedule

			# Check if parsedDate is in the past
			if parsedDate.isBefore now then return @set( "scheduleString", "past" )

			# If difference is more than 1 week, we want different formatting
			if parsedDate.diff( now, "days" ) > 7
				# If it's next year, add year suffix
				if parsedDate.year() > now.year()
					result = parsedDate.format "MMM Do 'YY"
				else
					result = parsedDate.format "MMM Do"

				return @set( "scheduleString", result )

			if parsedDate.diff( now, "days" ) < 1
				return @set( "scheduleString", "Later today" )
			

			# Date is within the next week, so just sat the day name — calendar() returns something like "Tuesday at 3:30pm", 
			# and we only want "Tuesday", so use this little RegEx to select everything before the first space.
			calndarWithoutTime = parsedDate.calendar().match( /\w+/ )[0]
			@set( "scheduleString", calndarWithoutTime )