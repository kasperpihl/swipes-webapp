###
 Brug evt:
 http://stackoverflow.com/questions/15912222/how-do-i-save-just-a-subset-of-a-backbone-models-attributes-to-the-server-witho
###

define ["momentjs"], ->
	Parse.Object.extend
		className: "ToDo"
		attrWhitelist: [
			"title"
			"order"
			"schedule"
			"completionDate"
			"repeatOption"
			"repeatDate"
			"repeatCount"
			"tags"
			"notes"
			"location"
			"priority"
			"deleted"
		]
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
			location: undefined
			priority: 0
			deleted: no
		initialize: ->
			# We use 'default' as the default value that triggers a new schedule 1 second in the past,
			# because null should be an allowed without triggering any logic, as null is used for
			# tasks scheduled as 'unspecified'
			if @get( "schedule" ) is "default" then @set( "schedule", @getDefaultSchedule() )

			# Convert schedule dates to actual date obj if for some reason it's a string (Like if it was saved to LocalStorage)
			@reviveDate "schedule"
			@reviveDate "completionDate"
			@reviveDate "repeatDate"

			# If model was created as a duplicate/repeat task, set up the new repeatDate
			@updateRepeatDate() unless @get( "repeatOption" ) is "never"

			@setScheduleStr()
			@setTimeStr()

			@on "change:tags", (me, tags) =>
				if tags.length then @syncTags tags

			@on "change:schedule", =>
				@setScheduleStr()
				@setTimeStr()
				@set( "selected", no )

			@on "change:completionDate", =>
				@setCompletionStr()
				@setCompletionTimeStr()
				@set( "selected", no )

			@on "change:schedule", => @reviveDate "schedule"
			@on "change:completionDate", => @reviveDate "completionDate"
			@on "change:repeatDate", => @reviveDate "repeatDate"

			@on( "change:repeatOption", @setRepeatOption )
			@on( "destroy", @cleanUp )

			if @has "completionDate"
				@setCompletionStr()
				@setCompletionTimeStr()

			saveOrder = => @save()
			debouncedSaveOrder = _.debounce( saveOrder, 3000 )

			@on "change:order", =>
				debouncedSaveOrder()
				if @get( "order" )? and @get( "order" ) < 0
					console.error "Model order value set to less than 0"
		reviveDate: (prop) ->
			if typeof @get( prop ) is "string"
				@set( prop, new Date( @get prop ), { silent: yes } )
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

		getTagStrList: ->
			if @has "tags"
				return _.invoke( @get( "tags" ), "get", "title" )
			else
				return []
		getDayWithoutTime: (day) ->
			fullStr = day.calendar()
			timeIndex = fullStr.indexOf( " at " )

			# Date is within the next week, so just sat the day name — calendar() returns something like "Tuesday at 3:30pm",
			# and we only want "Tuesday", so use this little RegEx to select everything before the first space.
			if timeIndex isnt -1
				return fullStr.slice( 0, timeIndex )
			else
				return fullStr
		syncTags: (tags) ->
			pointers = ( tag.id for tag in tags when !tag.has "title" )

			if pointers.length
				# remove pointers
				tags = _.reject tags, (t) -> _.contains( pointers, t.id )

				actualTags = @getTagsFromPointers pointers
				tags.push tag for tag in actualTags

				@set( "tags", tags, { silent: yes } )
		getTagsFromPointers: (pointers) ->
			result = []
			for tagid in pointers
				tag = _.findWhere( swipy.tags.models, { id: tagid } )
				if tag then result.push tag

			return result
		setScheduleStr: ->
			schedule = @get "schedule"
			if !schedule
				return @set( "scheduleStr", "unspecified" )

			now = moment()
			parsedDate = moment schedule
			dayDiff =  Math.abs parsedDate.diff( now, "days" )

			# If difference is more than 1 week, we want different formatting
			if dayDiff >= 6
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
			if parsedDate.diff( now, "days" ) <= -6
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
			if @get( "schedule" ) and option isnt "never"
				@set( "repeatDate", @getNextDate option )
			else
				@set( "repeatDate", null )

		updateRepeatDate: ->
			option = @get "repeatOption"

			if @get( "schedule" ) and option isnt "never"
				@set( "repeatDate", @getNextDate option )
			else
				@set( "repeatDate", null )

		isWeekend: (schedule) ->
			if schedule.getDay() is 0 or schedule.getDay() is 6 then return yes
			else return no

		isWeekday: (schedule) ->
			return !@isWeekend schedule

		getMonFriSatSunFromDate: ( schedule, completionDate ) ->
			if @isWeekday schedule
				@getNextWeekDay completionDate
			else
				@getNextWeekendDay completionDate

		getNextWeekDay: (date) ->
			# If date is friday, go to next monday, else go to tomorrow
			return date.add( "days", if date.day() is 5 then 3 else 1 ).toDate()

		getNextWeekendDay: (date) ->
			# If date is sunday, go to next saturday, else go to tomorrow (Which will always be sunday)
			return date.add( "days", if date.day() is 0 then 6 else 1 ).toDate()

		getNextDate: (option) ->
			if @has "completionDate"
				repeatDate = @get "repeatDate"
				completionDate = @get "completionDate"

				if repeatDate
					if repeatDate.getTime() > completionDate.getTime() then return repeatDate
					else switch option
						when "every week", "every month", "every year"
							date = moment @get "schedule"
						else
							date = moment completionDate
				else
					date = moment completionDate
			else
				date = moment @get "schedule"

				# If we moved the task from scheduled to today and completed it, use the old repeatDate instead of the
				# modified date.
				repeatDate = @get "repeatDate"
				if repeatDate and repeatDate.getTime() > @get( "schedule" ).getTime()
					date = moment repeatDate

			switch option
				when "every day" then date.add( "days", 1 ).toDate()
				when "every week", "every month", "every year"
					type = option.replace( "every ", "" ) + "s"
					if @has "completionDate"
						# In this case, date is the scheduled date
						diff = moment( @get "completionDate" ).diff( date, type, yes )
					else
						diff = 1

					date.add( type, Math.ceil diff ).toDate()
				when "mon-fri or sat+sun"
					@getMonFriSatSunFromDate( @get( "schedule" ), date )
				# "never" + catch-all
				else null

		sanitizeDataForDuplication: (data) ->
			# Make sure to only duplicate the white-listed attributes
			sanitizedData = _.clone data
			sanitizedData = _.pick( sanitizedData, @attrWhitelist )

			# Duplicate should have no repeat options
			sanitizedData.repeatCount = 0
			sanitizedData.repeatOption = "never"
			sanitizedData.repeatDate = null

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
			_.clone @attributes
		###
		toJSON: ->
			console.log "toJSON called!!!", _.pick( @attributes, @attrWhitelist )
			_.pick( @attributes, @attrWhitelist )
		###
		cleanUp: ->
			@off()
