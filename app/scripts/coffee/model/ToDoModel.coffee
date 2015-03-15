###
 Brug evt:
 http://stackoverflow.com/questions/15912222/how-do-i-save-just-a-subset-of-a-backbone-models-attributes-to-the-server-witho
###

define ["js/model/BaseModel", "js/utility/TimeUtility" ,"momentjs"],( BaseModel, TimeUtility ) ->
	BaseModel.extend
		className: "ToDo"
		idAttribute: "objectId"
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
			"parentLocalId"
			"priority"
			"origin"
			"originIdentifier"
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
			parentLocalId: null
			priority: 0
			deleted: no
			origin: null
			originIdentifier: null
		set: ( key, val, options ) ->
			Backbone.Model.prototype.set.apply @ , arguments
			attrs = {}
			if key is null or typeof key is 'object'
				attrs = key
				options = val
			else 
				attrs[ key ] = val
			if options and options.localSync
				BaseModel.prototype.doSync.apply @ , []
		save: ->
			shouldSync = BaseModel.prototype.handleForSync.apply @ , arguments
			Backbone.Model.prototype.save.apply @ , arguments
			if shouldSync
				BaseModel.prototype.doSync.apply @ , []
		constructor: ( attributes ) ->
			if attributes.tags and attributes.tags.length > 0
				attributes.tags = @handleTagsFromServer attributes.tags
			if attributes.subtasksLocal
				delete attributes.subtasksLocal
			BaseModel.apply @, arguments
			if attributes.parentLocalId
				identifier = attributes.parentLocalId
				parentModel = swipy.todos.find( 
					( model ) ->
						return true if identifier? and model.id is identifier
						false
				)
				if parentModel
					parentModel.addSubtask @
		linkToParent: (parent) ->
			parent.addSubtask @
		deleteSubtask: ( model ) ->
			currentSubtasks = @get "subtasksLocal"
			return false if !currentSubtasks
			for subtask, index in currentSubtasks
				if subtask.id is model.id
					currentSubtasks.splice(index, 1)
					@set "subtasksLocal", currentSubtasks, {localSync: true}
					return
					
		hasSubtask: ( model ) ->
			currentSubtasks = @get "subtasksLocal"
			return false if !currentSubtasks
			for subtask in currentSubtasks
				if subtask.id is model.id
					return true
			return false
		addSubtask: ( model ) ->
			currentSubtasks = @get "subtasksLocal"
			if !currentSubtasks
				currentSubtasks = []
			currentSubtasks.push( model )
			@set "subtasksLocal", currentSubtasks, {localSync: true}
			return @model
		addNewSubtask: ( title, from ) ->
			currentSubtasks = @getOrderedSubtasks()
			parentLocalId = @id
			order = currentSubtasks.length
			if from
				swipy.analytics.sendEvent( "Action Steps", "Added", from, title.length )
				swipy.analytics.sendEventToIntercom( "Added Action Step", { "From": "Input", "Length": title.length })
			swipy.todos.create { title, parentLocalId, order }

			#@addSubtask newSubtask
		deleteObj: ->
			for subtask in @getOrderedSubtasks()
				subtask.deleteObj()
			if @get "parentLocalId"
				parent = swipy.todos.get(@get("parentLocalId"))
				if parent
					parent.deleteSubtask( @ )
			BaseModel.prototype.deleteObj.apply @ , arguments
		initialize: ->
			# We use 'default' as the default value that triggers a new schedule 1 second in the past,
			# because null should be an allowed without triggering any logic, as null is used for
			# tasks scheduled as 'unspecified'
			if @get( "schedule" ) is "default" then @scheduleTask @getDefaultSchedule()

			# Convert schedule dates to actual date obj if for some reason it's a string (Like if it was saved to LocalStorage)
			@reviveDate "schedule"
			@reviveDate "completionDate"
			@reviveDate "repeatDate"

			# If model was created as a duplicate/repeat task, set up the new repeatDate
			##@updateRepeatDate() unless @get( "repeatOption" ) is "never"

			@setScheduleStr()
			@setTimeStr()

			@on "change:tags", (me, tags) =>
				if !tags then @updateTags []
				else @syncTags tags

			@on "change:schedule", =>
				@setScheduleStr()
				@setTimeStr()
				@save( "selected", no )
				@reviveDate "schedule"

			@on "change:completionDate", =>
				@setCompletionStr()
				@setCompletionTimeStr()
				@save( "selected", no )
				@reviveDate "completionDate"

			@on "change:repeatDate", => @reviveDate "repeatDate"

			##@on( "change:repeatOption", @setRepeatOption )
			@on( "destroy", @cleanUp )

			if @has "completionDate"
				@setCompletionStr()
				@setCompletionTimeStr()

		reviveDate: (prop) ->
			value = @handleDateFromServer @get( prop )
			@set prop, value, { silent: true }
		
		isSubtask: ->
			if @get "parentLocalId"
				return true
			else 
				return false
		getOrderedSubtasks: ->
			swipy.todos.getSubtasksForModel @
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
				@scheduleTask( new Date schedule )

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

				@save( "tags", tags, { silent: yes } )
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
			format = if swipy.settings?.get("Setting24HourClock") then "H:mm" else "h:mmA"

			@set( "timeStr", moment( schedule ).format format )

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

			sanitizedData.parentLocalId = null

			sanitizedData.origin = null
			sanitizedData.originIdentifier = null

			return sanitizedData

		getRepeatableDuplicate: ->
			if @has "repeatDate"
				return new @constructor @sanitizeDataForDuplication( @toJSON() )
			else
				throw new Error "You're trying to repeat a task that doesn't have a repeat date"
				return
		toJSON: ->
			@set( "state", @getState() )
			clonedAttributes = _.clone @attributes
			###if clonedAttributes.title and clonedAttributes.title.length > 0
				clonedAttributes.title = _.escape(clonedAttributes.title)
			if clonedAttributes.notes and clonedAttributes.notes.length > 0
				clonedAttributes.notes = _.escape(clonedAttributes.notes)###
			clonedAttributes
		cleanUp: ->
			@off()



		togglePriority: ->
			if @get "priority"
				@save( "priority", 0, { sync: true } )
			else
				@save( "priority", 1 , { sync: true } )
			if @get("priority") then priorityLabel = "On" else priorityLabel = "Off"
			swipy.analytics.sendEvent( "Tasks", "Priority", priorityLabel )
			swipy.analytics.sendEventToIntercom("Update Priority",  { "Assigned" : priorityLabel } )
		scheduleTask: ( date ) ->
			updateObj = {
				schedule: date
				completionDate: null
			}
			if !@isSubtask()
				updateObj.order = -1
			
			@unset "schedule"
			@save(updateObj,
				sync: true
			)

		
		completeRepeatedTask: ->
			timeUtil = new TimeUtility()
			nextDate = timeUtil.getNextDateFrom( @get("repeatDate"), @get "repeatOption"  )
			return if !nextDate
			duplicate = @getRepeatableDuplicate()

			# Make sure we can actually duplicate the task...
			return false unless duplicate

			swipy.todos.add duplicate
			duplicate.completeTask()

			@copyActionStepsToDuplicate duplicate

			@save({
				schedule: nextDate
				repeatCount: @get( "repeatCount" ) + 1
				repeatDate: nextDate
				},{ sync: true }
			)

		copyActionStepsToDuplicate: ( duplicate ) ->
			for subtask in @getOrderedSubtasks()
				parentLocalId = duplicate.get "tempId" 
				parentLocalId = duplicate.id if duplicate.id?
				attributes = 
					title: subtask.get "title"
					order: subtask.get "order"
					parentLocalId: parentLocalId
					completionDate: subtask.get "completionDate"
					schedule: subtask.get "schedule"

				swipy.todos.create attributes

				if subtask.get "completionDate"
					subtask.scheduleTask()


		completeTask: ->
			if @has "repeatDate"
				return @completeRepeatedTask()
			@save "completionDate" , new Date() , { sync: true }


		setRepeatOption: ( repeatOption ) ->
			repeatDate = null
			if @get( "schedule" ) and repeatOption isnt "never"
				repeatDate =  @get "schedule"
			@save({ repeatDate, repeatOption },{ sync: true })
			swipy.analytics.sendEvent( "Tasks", "Recurring", repeatOption )
			swipy.analytics.sendEventToIntercom( "Recurring Task", { "Reoccurrence": repeatOption } )

		updateOrder: ( order, opt ) ->
			if order == @get "order"
				return
			options = { sync: true }
			for key, value of opt
				options[key] = value
			@save "order", order, options

		updateTags: ( tags ) ->
			@unset "tags", { silent: true }
			@save "tags", tags, { sync: true }

		updateTitle: ( title ) ->
			@save "title", title, { sync: true }

		updateNotes: ( notes ) ->
			@save "notes", notes, { sync: true }




		updateFromServerObj: ( obj, recentChanges ) ->
			BaseModel.prototype.updateFromServerObj.apply @, arguments
			return if @get "deleted"
			dateKeys = [ "schedule", "completionDate", "repeatDate" ]
			for attribute in @attrWhitelist
				continue if !obj[ attribute ]?
				continue if recentChanges? and _.indexOf recentChanges, attribute isnt -1  
				val = obj[ attribute ]
				if attribute is "tags"
					val = @handleTagsFromServer val
				else if _.indexOf(dateKeys, attribute) isnt -1
					val = @handleDateFromServer val
				@set attribute, val, { localSync: true } if val isnt @get(attribute)
			BaseModel.prototype.doSync.apply( @ )
			false

		handleTagsFromServer: ( tags ) ->
			modelTags = []
			for tag in tags
				if !tag.objectId
					continue
				model = swipy.tags.get tag.objectId
				if model
					modelTags.push model
			modelTags

		handleDateFromServer: ( date ) ->
			if typeof date is "string"
				date = new Date date
			else if _.isObject( date ) and date.__type is "Date"
				date = new Date date.iso
			date