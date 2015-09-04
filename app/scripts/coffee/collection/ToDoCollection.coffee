define ["js/model/sync/ToDoModel", "localStorage", "momentjs"], ( ToDoModel ) ->
	Backbone.Collection.extend
		model: ToDoModel
		localStorage: new Backbone.LocalStorage("ToDoCollection")
		initialize: ->
			_.bindAll( @ , "changedSchedule", "addChangeListenerForBridge" )
			@on( "change:deleted", (model, deleted) => 
				if !deleted
					@add model
			)
			@on "reset", ->
				removeThese = []
				removeThese.push m for m in @models when m.get "deleted"
				@remove m for m in removeThese

				@invoke( "set", { rejectedByTag: no, rejectedBySearch: no } )
		createAction: (parentModel, str, options) ->
			newTodo = @create {"parentLocalId": parentModel.id, "projectLocalId": parentModel.get("projectLocalId"), "title": str, "animateIn": true }
			if newTodo.get("projectLocalId")
				capitalizedName = swipy.slackCollections.users.me().capitalizedName()
				sofiMessage = capitalizedName + " added the action \"" + newTodo.getTaskLinkForSlack() + "\" to the task \"" + parentModel.getTaskLinkForSlack() + "\""
				swipy.slackSync.sendMessageAsSofi(sofiMessage, newTodo.get("projectLocalId"))
			
			newTodo.save({}, {sync:true})
		createTask: (str, options) ->

			tags = @parseTags str
			title = @parseTitle str
			animateIn = yes

			# If user is trying to add
			if !title
				msg = "You cannot create a todo by simply adding a tag. We need a title too. Titles should come before tags when you write out your task."
				alert( msg )
				return

			newTodo = @create { title, animateIn }
			if options
				newTodo.set( "projectLocalId", options.projectLocalId ) if options.projectLocalId
				newTodo.set( "toUserId", options.toUserId) if options.toUserId
				newTodo.set( "schedule", options.schedule) if options.schedule
			#newTodo.set( "tags", tags )
			if newTodo.get("projectLocalId")
				capitalizedName = swipy.slackCollections.users.me().capitalizedName()
				sofiMessage = capitalizedName + " added the task \"" + newTodo.getTaskLinkForSlack() + "\"";
				targetChannel = newTodo.get("projectLocalId")
				toUser = swipy.slackCollections.users.get(options.targetUserId) if options.targetUserId
				targetChannel = "@"+toUser.get("name") if toUser
				swipy.slackSync.sendMessageAsSofi(sofiMessage, targetChannel)
			newTodo.save({}, {sync:true})

			swipy.analytics.sendEvent("Tasks", "Added", "Input", title.length )
			swipy.analytics.sendEventToIntercom( "Added Task", { "From": "Input", "Length": title.length } )

			newTodo
		parseTags: (str) ->
			result = str.match /#(.[^,#]+)/g

			if result
				# Trim white space and remove #-character from results
				tagNameList = ( $.trim tag.replace("#", "") for tag in result )
				tags = []

				for tagName in tagNameList
					tag = swipy.collections.tags.getTagByName tagName
					if !tag?
						tag = swipy.collections.tags.create( title: tagName )
						tag.save({}, {sync:true})

					tags.push tag

				return tags
			else
				return []

		parseTitle: (str) ->
			if str[0] is "#" then return ""

			result = str.match(/[^#]+/)?[0]
			if result then result = $.trim result
			return result

		repairActionStepsRelations: ->
			lostActionSteps = @filter (m) -> m.has("parentLocalId")
			parentsById = {}
			for actionStep in lostActionSteps
				parentId = actionStep.get "parentLocalId"
				parent = parentsById[ parentId ]
				if !parent
					parent = @get(parentId)
					parentsById[parentId] = parent
				if parent and !parent.hasSubtask(actionStep)
					actionStep.linkToParent(parent)
		getMyActive: ->
			@filter (m) -> m.get("isMyTask") and m.getState() is "active" and !m.isSubtask()
		getActive: ->
			@filter (m) -> m.getState() is "active" and !m.isSubtask()
		getScheduled: ->
			@filter (m) -> m.getState() is "scheduled" and !m.isSubtask()
		getScheduledLaterToday: ->
			nowMoment = moment(new Date())
			@filter (m) -> 
				if m.getState() is "scheduled" and !m.isSubtask()
					return false if !m.get("schedule")? or !m.get("schedule")
					return nowMoment.isSame(m.get("schedule"), "day")
					#if nowMoment.isSame(m.get("scheduled"))
				return false
		getCompleted: ->
			@filter (m) -> m.getState() is "completed" and !m.isSubtask()
		getCompletedToday: ->
			nowMoment = moment(new Date())
			@filter (m) -> 
				if m.getState() is "completed" and !m.isSubtask()
					return false if !m.get("completionDate")? or !m.get("completionDate")
					return nowMoment.isSame(m.get("completionDate"), "day")
					#if nowMoment.isSame(m.get("scheduled"))
				return false
		getSelected: (model) ->
			@filter (m) -> m.get("selected") or model? and m.cid is model.cid
		getSubtasksForModel: ( model ) ->
			@sortBy( "order" ).filter (m) -> m.get( "parentLocalId" ) is model.id
		getScheduledAsJSONText: ->
			scheduled = @filter (m) -> m.getState() is "scheduled" and !m.isSubtask()
			tasksJSON = _.invoke( scheduled, "toJSON" )
			JSON.stringify({"objects":"test"})
		getActiveList: ->
			route = swipy.router.getCurrRoute()
			switch route
				when "", "tasks/now", "tasks/later", "tasks/done"
					if route is "" or route is "tasks/now"
						return "todo"
					else if route is "tasks/later"
						return "scheduled"
					else if route is "tasks/done"
						return "completed"
				else return "todo"
		getTasksTaggedWith: (tags, filterOnlyCurrentTasks) ->
			activeList = @getActiveList()

			switch activeList
				when "todo" then models = @getActive()
				when "scheduled" then models = @getScheduled()
				else models = @getCompleted()

			_.filter models, (m) ->
				return false unless m.has "tags"

				# If string, wrap it in an array so we can loop over it
				if typeof tags isnt "object" then tags = [tags]

				# This multi-dimensional loop returns true if
				# the model has all of the provided tags in it's tags property
				return _.all( tags, (tag) -> _.contains( m.getTagStrList(), tag )  )
		deselectAllTasks: ->
			selectedTasks = @getSelected()
			for task in selectedTasks
				task.set("selected",false)





		# Bridge for Mac App notifications + badge
		addChangeListenerForBridge: ->
			@debouncedHandler = _.debounce( @changedSchedule, 50 )
			@off( "change:schedule add remove change:completionDate", @debouncedHandler )
			@on( "change:schedule add remove change:completionDate", @debouncedHandler )
			@changedSchedule()
		changedSchedule: ->
			activeTasks = @getActive()
			scheduledTasksForNotifications = @prepareScheduledForNotifications()
			swipy.bridge.callHandler("update-notification", { "number": activeTasks.length, "notifications": scheduledTasksForNotifications })
		prepareScheduledForNotifications: ->
			scheduledTasks = _.sortBy(_.invoke(@getScheduled(), "toJSON" ), (obj) ->
				return 0 if !obj.schedule? or !obj.schedule
				date = new Date(obj.schedule)
				return date.getTime()
			)
			preparedArray = []
			for task in scheduledTasks
				if !task.schedule? or !task.schedule
					continue
				preparedArray.push(_.pick(task,"schedule", "title", "objectId", "priority"))
			preparedArray