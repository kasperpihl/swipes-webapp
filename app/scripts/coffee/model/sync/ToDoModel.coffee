###
 Brug evt:
 http://stackoverflow.com/questions/15912222/how-do-i-save-just-a-subset-of-a-backbone-models-attributes-to-the-server-witho
###

define ["js/model/sync/BaseModel", "js/utility/TimeUtility" ,"momentjs"],( BaseModel, TimeUtility ) ->
	BaseModel.extend
		className: "ToDo"
		attrWhitelist: [
			"attachments"
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
			"projectLocalId"
			"projectOrder"
			"origin"
			"originIdentifier"
			"toUserId"
			"assignees"
		]
		defaults:
			title: ""
			order: -1
			schedule: null
			completionDate: null
			repeatOption: "never"
			repeatDate: null
			repeatCount: 0
			tags: null
			attachments:null
			notes: ""
			location: undefined
			parentLocalId: null
			priority: 0
			projectLocalId: null
			projectOrder: -1
			deleted: no
			origin: null
			originIdentifier: null
			toUserId: null
			assignees: null
		constructor: ( attributes ) ->
			if attributes.tags and attributes.tags.length > 0
				attributes.tags = @handleTagsFromServer attributes.tags
			if attributes.subtasksLocal
				delete attributes.subtasksLocal
			BaseModel.apply @, arguments
			if attributes.parentLocalId
				identifier = attributes.parentLocalId
				parentModel = swipy.collections.todos.find(
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
		uncompletedSubtasks: ->
			uncompletedSubtasks = []
			currentSubtasks = @get "subtasksLocal"
			return uncompletedSubtasks if !currentSubtasks
			for subtask in currentSubtasks
				if !subtask.get("completionDate")
					uncompletedSubtasks.push(subtask)
			uncompletedSubtasks
		getType: ->
			type = "Personal"
			projectLocalId = @get("projectLocalId")
			if projectLocalId
				if projectLocalId.startsWith("D")
					if projectLocalId is swipy.slackCollections.channels.slackbot().id
						type = "Slackbot"
					else
						type = "DM"
				if projectLocalId.startsWith("C")
					type = "Channel"
				if projectLocalId.startsWith("G")
					type = "Group"
			type

		hasSubtask: ( model ) ->
			currentSubtasks = @get "subtasksLocal"
			return false if !currentSubtasks
			for subtask in currentSubtasks
				if subtask.id is model.id
					return true
			return false
		addSubtask: ( model, save ) ->
			currentSubtasks = @get "subtasksLocal"
			if !currentSubtasks
				currentSubtasks = []
			currentSubtasks.push( model )
			if save and (!model.get("parentLocalId") or model.get("parentLocalId") isnt @identifier)
				model.save "parentLocalId", @id, {sync: true}
			@set "subtasksLocal", currentSubtasks, {localSync: true}
			if save
				@save {}, {sync:true}
			return @model
		addNewSubtask: ( title, from ) ->
			currentSubtasks = @getOrderedSubtasks()
			parentLocalId = @id
			order = currentSubtasks.length
			swipy.collections.todos.create { title, parentLocalId, order }

			#@addSubtask newSubtask
		getAssignees: ->
			currentAssignees = @get "assignees"
			if !currentAssignees
				currentAssignees = []
			currentAssignees
		assign: ( userIds, save ) ->
			if _.isString(userIds)
				userIds = [userIds]
			me = swipy.slackCollections.users.me()
			throw new Error("ToDoModel assign: userIds must be either array or string") if !_.isArray(userIds)
			assignedSelf = "No"
			currentAssignees = @getAssignees()
			for userId in userIds
				targetUser = userId
				if userId is me.id
					assignedSelf = "Yes"
				if _.indexOf( currentAssignees, userId) is -1
					inserted = true
					currentAssignees.push( userId )
			if inserted?
				@set("assignees": null)

				saveObj = {"assignees": currentAssignees }
				if !@get("schedule")
					saveObj.schedule = new Date()

				if save
					@save saveObj, {sync:true}
				else
					@set saveObj, {localSync: true}
			if assignedSelf is "No" and targetUser
				type = "Assign Invite"
				swipy.api.callAPI("invite/slack", "POST", {invite: {"slackUserId": targetUser, "type": type}}, (res, error) =>
					console.log "res from invite", res, error
					if res and res.ok
						swipy.analytics.logEvent("Invite Sent", {"Hours Since Signup": res.hoursSinceSignup, "From" : "Assigning" })
				)

			swipy.analytics.logEvent("[Engagement] Assigned Task", {"Type": @getType(), "To Self": assignedSelf})
		userIsAssigned:(userId) ->
			currentAssignees = @get "assignees"
			return false if !currentAssignees
			return _.indexOf(currentAssignees, userId) isnt -1
		unassign: ( userIds, save ) ->
			if _.isString(userIds)
				userIds = [userIds]

			throw new Error("ToDoModel assign: userIds must be either array or string") if !_.isArray(userIds)

			currentAssignees = @get "assignees"
			return false if !currentAssignees
			for assignee, index in currentAssignees
				if _.indexOf(userIds, assignee) isnt -1
					removed = true
					currentAssignees.splice(index, 1)

			if removed?
				@set("assignees": null)
				if save
					@save {"assignees": currentAssignees}, {sync:true}
				else
					@set "assignees", currentAssignees, {localSync: true}


		deleteObj: ->
			for subtask in @getOrderedSubtasks()
				subtask.deleteObj()
			if @get "parentLocalId"
				parent = swipy.collections.todos.get(@get("parentLocalId"))
				if parent
					parent.deleteSubtask( @ )
			BaseModel.prototype.deleteObj.apply @ , arguments
		initialize: ->

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
				#@save( "selected", no )
				@reviveDate "schedule"

			@on "change:completionDate", =>
				@setCompletionStr()
				@setCompletionTimeStr()
				#@save( "selected", no )
				@reviveDate "completionDate"

			@checkAssigned()
			@on "change:toUserId change:assignees", =>
				@checkAssigned()
			@on "change:repeatDate", => @reviveDate "repeatDate"

			##@on( "change:repeatOption", @setRepeatOption )
			@on( "destroy", @cleanUp )

			if @has "completionDate"
				@setCompletionStr()
				@setCompletionTimeStr()
			@setRestrictedForMe()
		setRestrictedForMe: ->
			me = swipy.slackCollections.users.me()
			if @get("toUserId")
				if @get("toUserId") isnt me.id and @get("userId") isnt me.id
					@set("restrictedForMe",true)
		checkAssigned: ->
			me = swipy.slackCollections.users.me()
			if @get("toUserId") is me.id or @get("assignees") and _.indexOf(@get("assignees"), me.id) isnt -1
				@set("isMyTask", true)
			else @set("isMyTask", false)

			if @get("toUserId") or @get("assignees") and @get("assignees").length > 0
				@set("isAssigned", true)
			else @set("isAssigned", false)

		getTaskLinkForSlack: ->
			title = @get("title")
			if title.length > 30
				title = title.substring(0,30)+'...'
			return "<http://swipesapp.com/task/" + @id + "|" + title + ">"
		isSubtask: ->
			if @get("parentLocalId") then return true else false
		getOrderedSubtasks: ->
			swipy.collections.todos.getSubtasksForModel @
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

		getValidatedSchedule: ->
			schedule = @get "schedule"

			if typeof schedule is "string"
				@scheduleTask( new Date schedule )

			return @get "schedule"
		getDefaultSchedule: ->
			now = new Date()
			now.setSeconds now.getSeconds() - 1
			return now
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
				tag = _.findWhere( swipy.collections.tags.models, { id: tagid } )
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

			format = if swipy.settings?.get("Setting24HourClock") then "H:mm" else "h:mmA"
			# We have a completionDate set, update timeStr prop
			@set( "completionTimeStr", moment( completionDate ).format format )



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
		toRenderJSON: ->
			clonedAttributes = @toJSON()

			clonedAttributes
		toJSON: ->
			@set( "state", @getState() )
			clonedAttributes = _.clone @attributes

			clonedAttributes
		attachmentsForService:(service) ->
			foundAttachments = []
			for attachment in @get("attachments")
				if attachment.service is service
					foundAttachments.push(attachment)
			return no if foundAttachments.length is 0
			return foundAttachments
		cleanUp: ->
			@off()



		togglePriority: ->
			if @get "priority"
				@save( "priority", 0, { sync: true } )
			else
				@save( "priority", 1 , { sync: true } )
			if @get("priority") then priorityLabel = "On" else priorityLabel = "Off"
		scheduleTask: ( date ) ->
			updateObj = {
				schedule: date
				completionDate: null
			}

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

			swipy.collections.todos.add duplicate
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

				swipy.collections.todos.create attributes

				if subtask.get "completionDate"
					subtask.scheduleTask()


		completeTask: ->
			if @has "repeatDate"
				return @completeRepeatedTask()
			@save "completionDate" , new Date() , { sync: true }

		deleteTask: ->
			@save "deleted" , true , { sync: true }

		setRepeatOption: ( repeatOption ) ->
			repeatDate = null
			if @get( "schedule" ) and repeatOption isnt "never"
				repeatDate =  @get "schedule"
			@save({ repeatDate, repeatOption },{ sync: true })
		updateOrder: ( attr, order, opt ) ->
			if attr isnt "order" and attr isnt "projectOrder"
				throw new Error("TodoModel updateOrder: invalid order attribute")
			if order == @get attr
				return
			options = { sync: true }
			for key, value of opt
				options[key] = value
			@save attr, order, options

		updateTags: ( tags ) ->
			@unset "tags", { silent: true }
			@save "tags", tags, { sync: true }

		updateTitle: ( title ) ->
			@save "title", title, { sync: true }

		updateNotes: ( notes ) ->
			@save "notes", notes, { sync: true }


		# Sent when syncing the model every time an attribute in @attrWhiteList is hit
		# Modify and return val
		handleAttributeAndValueFromServer: (attribute, val) ->
			if attribute is "tags"
				val = @handleTagsFromServer val

			dateKeys = [ "schedule", "completionDate", "repeatDate" ]
			if _.indexOf(dateKeys, attribute) isnt -1
				val = @handleDateFromServer val
			val

		# Translate server json of tags into the collection and models
		handleTagsFromServer: ( tags ) ->
			modelTags = []
			return modelTags if !tags? or !tags or tags.length is 0
			for tag in tags
				if !tag.objectId
					continue
				model = swipy.collections.tags.get tag.objectId
				if model
					modelTags.push model
			modelTags
