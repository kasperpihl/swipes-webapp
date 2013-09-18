define ["backbone", "momentjs"], (Backbone, Moment) ->
	Backbone.Model.extend
		defaults: 
			title: ""
			order: undefined
			schedule: null
			completionDate: null
			repeatOption: "never"
			repeatDate: null
			repeatCount: 0
			tags: null
			notes: ""
			deleted: no
		initialize: ->
			# Schedule defaults to a new date object 1 second in the past
			@set( "schedule", @getDefaultSchedule() ) if @get( "schedule" ) is null

			@setScheduleStr()
			@setTimeStr()

			@on "change:schedule", =>
				@setScheduleStr()
				@setTimeStr()
		getDefaultSchedule: ->
			now = new Date()
			now.setSeconds now.getSeconds() - 1
			return now
		getValidatedSchedule: ->
			schedule = @get "schedule"
			if !schedule then return false

			if typeof schedule is "string"
				@set( "schedule", new Date schedule )

			return @get "schedule"
		setScheduleStr: ->
			schedule = @get "schedule"
			if !schedule 
				if @get "completionDate"
					@set( "scheduleString", "the past" )
					return @get "scheduleString"
				else
					return false

			now = moment()
			parsedDate = moment schedule

			# Check if parsedDate is in the past
			if parsedDate.isBefore() then return @set( "scheduleString", "the past" )

			# If difference is more than 1 week, we want different formatting
			dayDiff = parsedDate.diff( now, "days" )
			if dayDiff > 7
				# If it's next year, add year suffix
				if parsedDate.year() > now.year() then result = parsedDate.format "MMM Do 'YY"
				else result = parsedDate.format "MMM Do"

				return @set( "scheduleString", result )

			# Date is within the next week, so just sat the day name — calendar() returns something like "Tuesday at 3:30pm", 
			# and we only want "Tuesday", so use this little RegEx to select everything before the first space.
			calendarWithoutTime = parsedDate.calendar().match( /\w+/ )[0]

			# Change "Today" to "Later today"
			if calendarWithoutTime is "Today" then calendarWithoutTime = "Later today"
			
			@set( "scheduleString", calendarWithoutTime )
		setTimeStr: ->
			schedule = @get "schedule"
			if !schedule then return @set( "timeStr", undefined )
			
			# We have a schedule set, update timeStr prop
			@set( "timeStr", moment( schedule ).format "h:mmA" )
