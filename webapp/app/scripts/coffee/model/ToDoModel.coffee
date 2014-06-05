###
 Brug evt:
 http://stackoverflow.com/questions/15912222/how-do-i-save-just-a-subset-of-a-backbone-models-attributes-to-the-server-witho
###

define ["js/model/BaseModel", "js/utility/TimeUtility" ,"momentjs"],( BaseModel, TimeUtility ) ->
	BaseModel.extend
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
		set: ->
			BaseModel.prototype.handleForSync.apply @ , arguments
			Parse.Object.prototype.set.apply @ , arguments 
		constructor: ( attributes ) ->

			if attributes.tags and attributes.tags.length > 0
				modelTags = []
				hasTagsFromServer = null
				for tag in attributes.tags
					if !tag.objectId
						continue
					hasTagsFromServer = true
					model = swipy.tags.get tag.objectId
					if model
						modelTags.push model
				if hasTagsFromServer
					attributes.tags = modelTags
			Parse.Object.apply @, arguments
			
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
			##@updateRepeatDate() unless @get( "repeatOption" ) is "never"

			@setScheduleStr()
			@setTimeStr()

			@on "change:tags", (me, tags) =>
				if !tags then @set( "tags", [] )
				@syncTags tags

			@on "change:schedule", =>
				@setScheduleStr()
				@setTimeStr()
				@set( "selected", no )
				@reviveDate "schedule"
				@checkIfWeShouldListenForOrderChange()

			@on "change:completionDate", =>
				@setCompletionStr()
				@setCompletionTimeStr()
				@set( "selected", no )
				@reviveDate "completionDate"
				@checkIfWeShouldListenForOrderChange()

			@on "change:repeatDate", => @reviveDate "repeatDate"

			##@on( "change:repeatOption", @setRepeatOption )
			@on( "destroy", @cleanUp )

			if @has "completionDate"
				@setCompletionStr()
				@setCompletionTimeStr()

			saveOrder = => @save()
			@debouncedSaveOrder = _.debounce( saveOrder, 3000 )

			@checkIfWeShouldListenForOrderChange( no )
		checkIfWeShouldListenForOrderChange: (removeEventListeners) ->
			if @getState() is "active"
				if @get "title"
					if not @get "deleted"
						@listenForOrderChanges()
			else
				if removeEventListeners then @stopListeningForOrderChanges()
		listenForOrderChanges: ->
			@on( "change:order", @debouncedSaveOrder )
		stopListeningForOrderChanges: ->
			@off( "change:order", @debouncedSaveOrder )

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
			
			# Remove falsy values first
			tags = _.compact tags
			pointers = ( tag.id for tag in tags when !tag.has "title" )

			if pointers && pointers.length
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

		

		sanitizeDataForDuplication: (data) ->
			# Make sure to only duplicate the white-listed attributes
			sanitizedData = _.clone data
			sanitizedData = _.pick( sanitizedData, @attrWhitelist )

			# Duplicate should have no repeat options
			sanitizedData.repeatCount = 0
			sanitizedData.repeatOption = "never"
			sanitizedData.repeatDate = null

			return sanitizedData

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



		togglePriority: ->
			if @get "priority"
				@save( "priority", 0, { sync: true } )
			else
				@save( "priority", 1 , { sync: true } )

		scheduleTask: ( date ) ->
			@save({
				schedule: date,
				completionDate: null
			},
			sync: true
			)

		
		completeRepeatedTask: ->
			timeUtil = new TimeUtility()
			nextDate = timeUtil.getNextDateFrom( @get("repeatDate"), @get "repeatOption"  )
			console.log nextDate
			return if !nextDate
			duplicate = @getRepeatableDuplicate()

			# Make sure we can actually duplicate the task...
			return false unless duplicate

			duplicate.completeTask()
			swipy.todos.add duplicate

			@save({
				schedule: nextDate
				repeatCount: @get( "repeatCount" ) + 1
				repeatDate: nextDate
				},{ sync: true }
			)

		completeTask: ->
			if @has "repeatDate"
				return @completeRepeatedTask()
			@save "completionDate" , new Date() , { sync: true }


		setRepeatOption: ( repeatOption ) ->
			console.log repeatOption
			repeatDate = null
			if @get( "schedule" ) and repeatOption isnt "never"
				repeatDate =  @get "schedule"
			@save({ repeatDate, repeatOption },{ sync: true })
		
		
