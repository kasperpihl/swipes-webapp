define ["backbone", "momentjs"], (Backbone, Moment) ->
	Backbone.Model.extend
		defaults:
			title: ""
			order: undefined
			schedule: "default"
			completionDate: null
			repeatOption: "never"
			repeatDate: null
			repeatCount: 0
			tags: null
			notes: ""
			deleted: no

		initialize: ->
			# We use 'default' as the default value that triggers a new schedule 1 second in the past,
			# because null should be an allowed without triggering any logic, as null is used for
			# tasks scheduled as 'unspecified'
			if @get( "schedule" ) is "default" then @set( "schedule", @getDefaultSchedule() )

			# Convert schedule to date obj if for some reason it's a string
			if typeof @get( "schedule" ) is "string" then @set( "schedule", new Date @get( "schedule" ) )

			# If model was created as a duplicate/repeat task, set up the new repeatDate
			if @get( "repeatOption" ) isnt "never" then @set( "repeatDate", @getNextDate( @get "repeatOption" ) )

			@setScheduleStr()
			@setTimeStr()
			@syncTags()

			@on "change:schedule", =>
				@setScheduleStr()
				@setTimeStr()
				@updateRepeatDate()
				@set( "selected", no )

			@on "change:completionDate", =>
				@set( "selected", no )
				# These methods will unset the properties if no completionDate is defined
				@setCompletionStr()
				@setCompletionTimeStr()

			@on( "change:repeatOption", @setRepeatOption )
			@on( "destroy", @cleanUp )

			if @has "completionDate"
				@setCompletionStr()
				@setCompletionTimeStr()

			@on "change:order", =>
				if @get( "order" )? and @get( "order" ) < 0
					console.error "Model order value set to less than 0"

		getState: ->
			schedule = @getValidatedSchedule()

			# Check if completed
			if @get "completionDate"
				return "completed"

			else
				# Chck if active
				if schedule and schedule.getTime() <= new Date().getTime() then return "active"

				# Check if scheduled
				else return "scheduled"

		getDefaultSchedule: ->
			now = new Date()
			now.setSeconds now.getSeconds() - 1
			return now

		getValidatedSchedule: ->
			schedule = @get "schedule"

			if typeof schedule is "string"
				@set( "schedule", new Date schedule )

			return @get "schedule"

		getDayWithoutTime: (moment) ->
			# Date is within the next week, so just sat the day name — calendar() returns something like "Tuesday at 3:30pm",
			# and we only want "Tuesday", so use this little RegEx to select everything before the first space.
			return moment.calendar().match( /\w+/ )[0]

		syncTags: ->
			if @has( "tags" ) and swipy?.tags
				swipy.tags.add { title: tagName } for tagName in @get "tags"

		setScheduleStr: ->
			schedule = @get "schedule"
			if !schedule
				return @set( "scheduleStr", "unspecified" )

			now = moment()
			parsedDate = moment schedule


			# If difference is more than 1 week, we want different formatting
			if Math.abs( parsedDate.diff( now, "days" ) ) >= 7
				# If it's next year, add year suffix
				if parsedDate.year() > now.year() then result = parsedDate.format "MMM Do 'YY"
				else result = parsedDate.format "MMM Do"

				return @set( "scheduleStr", result )

			dayWithoutTime = @getDayWithoutTime parsedDate

			# Change "Today" to "Later today" if it's later than current time.
			if dayWithoutTime is "Today" and not parsedDate.isBefore()
				dayWithoutTime = "Later today"

			@set( "scheduleStr", dayWithoutTime )

		setTimeStr: ->
			schedule = @get "schedule"
			if !schedule then return @set( "timeStr", undefined )

			# We have a schedule set, update timeStr prop
			@set( "timeStr", moment( schedule ).format "h:mmA" )

		setCompletionStr: ->
			completionDate = @get "completionDate"
			if !completionDate then return @unset "completionStr"

			now = moment()
			parsedDate = moment completionDate

			# If difference is more than 1 week, we want different formatting
			if parsedDate.diff( now, "days" ) <= -7
				# If it's the previous year, add year suffix
				if parsedDate.year() < now.year() then result = parsedDate.format "MMM Do 'YY"
				else result = parsedDate.format "MMM Do"

				return @set( "completionStr", result )

			dayWithoutTime = @getDayWithoutTime parsedDate

			# Change "Today" to "Later today"
			if dayWithoutTime is "Today" then dayWithoutTime = "Earlier today"

			@set( "completionStr", dayWithoutTime )

		setCompletionTimeStr: ->
			completionDate = @get "completionDate"
			if !completionDate then return @unset "completionTimeStr"

			# We have a completionDate set, update timeStr prop
			@set( "completionTimeStr", moment( completionDate ).format "h:mmA" )

		setRepeatOption: (model, option) ->
			@set( "repeatDate", @getNextDate option )

		updateRepeatDate: ->
			if @get( "schedule" ) and @get( "repeatOption" ) isnt "never"
				@set( "repeatDate", @getNextDate( @get "repeatOption" ) )
			else
				@set( "repeatDate", null )

		getNextWeekday: ->
			console.warn "next week day not implemented yet!"
			new moment().toDate()

		getNextWeekendday: ->
			console.warn "next weekend day not implemented yet!"
			new moment().toDate()

		getNextDate: (option) ->
			date = moment @get "schedule"

			switch option
				when "every day" then date.add( "days", 1 ).toDate()
				when "every week" then date.add( "weeks", 1 ).toDate()
				when "every month" then date.add( "months", 1 ).toDate()
				when "every year" then date.add( "years", 1 ).toDate()
				when "min-fri" then @getNextWeekday()
				when "sat+sun" then @getNextWeekendday()
				# "never" + catch-all
				else null

		sanitizeDataForDuplication: (data) ->
			sanitizedData = _.clone data

			for prop in ["id", "state", "schedule", "scheduleStr", "completionDate", "completionStr", "completionTimeStr", "repeatDate"]
				delete sanitizedData[prop] if sanitizedData[prop]

			sanitizedData.schedule = @getScheduleBasedOnRepeatDate data.repeatDate
			sanitizedData.repeatCount++

			return sanitizedData

		getScheduleBasedOnRepeatDate: (repeatDate) ->
			# Look at completionDate and determine the correct date.
			return repeatDate

		getRepeatableDuplicate: ->
			if @has "repeatDate"
				return new @constructor @sanitizeDataForDuplication( @toJSON() )
			else
				throw new Error "You're trying to repeat a task that doesn't have a repeat date"
				return

		toJSON: ->
			@set( "state", @getState() )
			Backbone.Model::toJSON.apply( @, arguments )

		cleanUp: ->
			@off()