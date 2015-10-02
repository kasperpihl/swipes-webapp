###
	Get all the tasks from project, team member or personal (subcollection w/ filter)
	Receive action from TaskList about a drag/drop hit and handle the request
		Find out who's the sender, where does it want to go, and what actions would be available
	Receive select/unselect from TaskList
###
define ["underscore", "js/view/modal/UserPickerModal"], (_, UserPickerModal) ->
	class TaskHandler
		constructor: ->
			@bouncedReloadWithEvent = _.debounce( @reloadWithEvent, 5 )
		loadCollection: (collection) ->
			@collection = collection
			@collection.on("add remove reset change:order change:projectOrder change:schedule change:completionDate", @bouncedReloadWithEvent, @ )
			Backbone.on("show-assign", @didPressAssign, @)
			Backbone.on("move-to-now", @didMoveToNow, @)
		reloadWithEvent: ->
			Backbone.trigger("reload/taskhandler")
		taskCollectionIdFromHtmlId: (taskHtmlId) ->
			# #task-
			return if !taskHtmlId or !_.isString(taskHtmlId)

			taskHtmlId.substring(6)
		projectCollectionIdFromHtmlId: (projectHtmlId) ->
			# #sidebar-channel-
			return if !projectHtmlId or !_.isString(projectHtmlId)
			projectHtmlId.substring(17)
		memberCollectionIdFromHtmlId: (memberHtmlId) ->
			# #sidebar-member-
			return if !memberHtmlId or !_.isString(memberHtmlId)
			memberHtmlId.substring(16)

		###
			DragHandler Delegate
		###
		didCreateDragHandler: ( dragHandler ) ->
			@dragHandler = dragHandler
		idForEvent:(e) ->
			if e.path?
				for el in e.path
					$el = $(el)

					if !draggedId and ($el.hasClass("action-item") or $el.hasClass("task-item"))
						draggedId = "#" + $el.attr("id")
			else if e.originalTarget? or e.target?
				currentTarget = e.target if e.target?
				currentTarget = e.originalTarget if e.originalTarget?

				for num in [1..10]
					if currentTarget? and currentTarget
						if _.indexOf(currentTarget.classList, "action-item") isnt -1 or _.indexOf(currentTarget.classList, "task-item") isnt -1
							draggedId = "#" + currentTarget.id
						else
							currentTarget = currentTarget.parentNode
					else
						break
			draggedId
		dragHandlerDraggedIdsForEvent: (dragHandler, e ) ->
			draggedIds = []
			draggedId = @idForEvent(e)

			draggedTask = @collection.get( @taskCollectionIdFromHtmlId(draggedId) )
			#console.log @collection.toJSON(), draggedTask.toJSON()
			return [] if !draggedTask?

			#draggedTask.set("selected",true)
			selectedTasks = @collection.getSelected(draggedTask)

			titles = _.invoke(selectedTasks, "get", "title")
			$('.drag-mouse-pointer ul').html ""
			for title in titles
				$('.drag-mouse-pointer ul').append("<li>"+title+"</li>")
			for task in selectedTasks
				draggedIds.push("#task-"+task.id)

			draggedIds
		# Deal with dropped items from DragHandler if true is returned, callback must be called!
		dragHandlerDidHit: ( dragHandler, draggedIds, hit, callback ) ->
			draggedId = draggedIds[0]
			draggedTask = @collection.get( @taskCollectionIdFromHtmlId(draggedId) )

			return if !draggedTask?
			self = @
			selectedTasks = @collection.getSelected( draggedTask )

			return false if !hit?


			if hit.type is "task"
				hitTask = @collection.get( @taskCollectionIdFromHtmlId(hit.target) )
				return if !hitTask?

				if hit.position is "middle"
					hitTask.addSubtask draggedTask, true
					@bouncedReloadWithEvent()
				else if hit.position is "bottom" or hit.position is "top"

					fromOrder = draggedTask.get(@listSortAttribute)
					targetOrder = hitTask.get(@listSortAttribute)
					# if a task is moved up all affected should go down - otherwise up
					addition = if fromOrder > targetOrder then 1 else -1

					# If task is moved down and top is hit, or task is moved down and bottom is hit - adjust accordingly!
					targetOrder -= 1 if addition is -1 and hit.position is "top"
					targetOrder += 1 if addition is 1 and hit.position is "bottom"

					# get the order affected span and order depending if task is moved up or down
					lowestOrderAffected = if addition is 1 then targetOrder else fromOrder
					highestOrderAffected = if addition is 1 then fromOrder else targetOrder


					self = @
					# find all affected tasks and bump them one up or down
					@collection.each( (m) ->
						order = m.get(self.listSortAttribute)
						if order >= lowestOrderAffected and order <= highestOrderAffected and m isnt draggedTask
							m.updateOrder(self.listSortAttribute, order + addition )
					)

					# and selected tasks with order
					_.invoke(selectedTasks, "updateOrder", @listSortAttribute, targetOrder)
					@reloadWithEvent()
					setTimeout(
						=> _.invoke(selectedTasks, "set", "selected", false)
					, 400)
					isMyTasks = if @isMyTasks? then "Yes" else "No"
					swipy.analytics.logEvent("[Engagement] Reorder Task", {"Type": draggedTask.getType(), "Is My Tasks": isMyTasks})
					swipy.analytics.sendEventToIntercom("Reorder Task", {"Type": draggedTask.getType(), "Is My Tasks": isMyTasks})

			else if hit.type is "project"
				targetProject = swipy.slackCollections.channels.findWhere( {name: @projectCollectionIdFromHtmlId(hit.target)} )
				return if !targetProject?
				actions = []
				actions.push({name: "Copy", icon: "dragMenuCopy", action: "copy"})
				actions.push({name: "Move", icon: "dragMenuMove", action: "move"})
				swipy.modalVC.presentActionList(actions, {centerX: false, centerY: false, left: hit.pointerEvent.pageX, top: hit.pointerEvent.pageY}, (result) ->
					if result is "move"
						# and update selected tasks as well
						_.invoke(selectedTasks, "save", {"toUserId": null, "projectLocalId": targetProject.id, "selected": false}, {sync: true} )
						self.bouncedReloadWithEvent()
				)
			else if hit.type is "member"
				memberId = @memberCollectionIdFromHtmlId(hit.target)
				member = swipy.slackCollections.users.findWhere({name: memberId})

				return if !member?
				targetProject = swipy.slackCollections.channels.findWhere({user: member.id})
				name = member.get "name"
				actions = []
				if draggedTask.get("projectLocalId")
					if !draggedTask.userIsAssigned(memberId)
						actions.push({name: "Assign", icon:"dragMenuAssign", action: "assign"})

				actions.push({name: "Copy", icon: "dragMenuCopy", action: "copy"})
				actions.push({name: "Move", icon: "dragMenuMove", action: "move"})
				swipy.modalVC.presentActionList(actions, {centerX: false, centerY: false, left: hit.pointerEvent.pageX, top: hit.pointerEvent.pageY}, (result) ->
					if result is "assign"
						_.invoke(selectedTasks, "assign", member.id, false )
					if result is "unassign"
						_.invoke(selectedTasks, "unassign", member.id, false )
					if result is "move"
						# and update selected tasks as well
						_.invoke(selectedTasks, "save", {"toUserId": memberId, "projectLocalId": targetProject.id, "selected": false}, {sync: true} )
						self.bouncedReloadWithEvent()
				)
			false
		dragHandlerDidClick: (dragHandler, e) ->
			hitTarget = $(e.target)
			clickedId = @idForEvent(e)

			model = @collection.get( @taskCollectionIdFromHtmlId(clickedId) )

			taskCard = $(clickedId)
			@handleClickForModelAndTaskCard(e, model, taskCard)
			false

		###
			Task Action Step Delegate
		###
		taskActionStepComplete: (task, parentTaskModel) ->
			model = task.model

			model.completeTask()

			if model.get("projectLocalId")
				targetChannel = model.get("projectLocalId")
				capitalizedName = swipy.slackCollections.users.me().capitalizedName()

				if targetChannel isnt swipy.slackCollections.channels.slackbot().id
					sofiMessage = capitalizedName + " completed the action step \"" + model.getTaskLinkForSlack() + "\" from the task \"" + parentTaskModel.getTaskLinkForSlack() + "\"";
					swipy.slackSync.sendMessageAsSofi(sofiMessage, targetChannel)
			isMyTasks = if @isMyTasks? then "Yes" else "No"
			swipy.analytics.logEvent("[Engagement] Completed Action Step", {"Type": model.getType() , "Is My Tasks": isMyTasks})
			swipy.analytics.sendEventToIntercom("Completed Action Step", {"Type": model.getType() })
		###
			TaskCard Delegate
		###
		taskDidClick: (taskCard, e) ->
			@handleClickForModelAndTaskCard(e, taskCard.model, taskCard.$el)
		taskCardDidComplete: (taskCard) ->
			model = taskCard.model

			model.completeTask()

			if model.get("projectLocalId")
				targetChannel = model.get("projectLocalId")
				###if model.get("projectLocalId").startsWith("D")
					channel = swipy.slackCollections.channels.get(model.get("projectLocalId"))
					if channel
						targetChannel = "@" + channel.getName()###
				capitalizedName = swipy.slackCollections.users.me().capitalizedName()

				if targetChannel isnt swipy.slackCollections.channels.slackbot().id
					sofiMessage = capitalizedName + " completed the task \"" + model.getTaskLinkForSlack() + "\"";
					swipy.slackSync.sendMessageAsSofi(sofiMessage, targetChannel)
			isMyTasks = if @isMyTasks? then "Yes" else "No"
			swipy.analytics.logEvent("[Engagement] Completed Task", {"Type": model.getType() , "Is My Tasks": isMyTasks})
			swipy.analytics.sendEventToIntercom("Completed Tasks", {"Type": model.getType() })

			@bouncedReloadWithEvent()
		taskCardDoDelete: (task) ->
			model = task.model

			model.deleteTask()

			if model.get("projectLocalId")
				targetChannel = model.get("projectLocalId")
				capitalizedName = swipy.slackCollections.users.me().capitalizedName()

				if targetChannel isnt swipy.slackCollections.channels.slackbot().id
					sofiMessage = capitalizedName + " deleted the task \"" + model.getTaskLinkForSlack() + "\"";
					swipy.slackSync.sendMessageAsSofi(sofiMessage, targetChannel)

			isMyTasks = if @isMyTasks? then "Yes" else "No"
			swipy.analytics.logEvent("[Engagement] Deleted Task", {"Type": model.getType() , "Is My Tasks": isMyTasks})
			swipy.analytics.sendEventToIntercom("Deleted Tasks", {"Type": model.getType() })
		didMoveToNow: (taskCards) ->
			tasks = _.pluck( taskCards, "model" )
			deferredArr = []

			for taskCard in taskCards
				deferredArr.push taskCard.animateWithClass("fadeOutRight")

			$.when( deferredArr... ).then =>
				_.invoke(tasks, "scheduleTask", tasks[0].getDefaultSchedule())

		didPressAssign: (model, e) ->
			userPickerModal = new UserPickerModal()
			@pickerModel = model
			userPickerModal.dataSource = @
			userPickerModal.delegate = @
			userPickerModal.selectOne = false
			userPickerModal.searchField = true
			userPickerModal.title = "Assign People"
			userPickerModal.emptyMessage = "No more people to assign"
			userPickerModal.loadPeople()
			userPickerModal.render()
			userPickerModal.presentModal({ left: e.clientX, top:e.clientY+10, centerY: false })
		userPickerClickedUser: (targetUser) ->
			@pickerModel.assign( targetUser.id, true )
			if @pickerModel.get("projectLocalId")
				capitalizedName = swipy.slackCollections.users.me().capitalizedName()
				if swipy.slackCollections.users.me().id isnt targetUser.id
					sofiMessage = capitalizedName + " assigned you the task \"" + @pickerModel.getTaskLinkForSlack() + "\"";
					swipy.slackSync.sendMessageAsSofi(sofiMessage, "@" + targetUser.get("name"))
			#@pickerModel = null
			#@dismissModal()
		userPickerModalPeople: (userPickerModal) ->
			peopleToAssign = []
			model = @pickerModel
			me = swipy.slackCollections.users.me()
			if me?
				data = me.toJSON()
				if _.indexOf(model.getAssignees(), me.id) is -1
					peopleToAssign.push(data)
			channel = swipy.slackCollections.channels.get(model.get("projectLocalId"))
			if channel
				members = channel.get("members")
				userId = channel.get("user")
				if members
					for member in members
						user = swipy.slackCollections.users.get(member)
						continue if !user or user.id is me.id or user.get("deleted")
						data = user.toJSON()
						if _.indexOf(model.getAssignees(), user.id) is -1
							peopleToAssign.push(data)
				else if userId and _.indexOf(model.getAssignees(), userId) is -1
					user = swipy.slackCollections.users.get(userId)
					if user
						peopleToAssign.push(user.toJSON())



			###swipy.slackCollections.users.each( (user) =>
				return if user.id is me.id or user.get("deleted") or user.get("is_bot") or user.id is "USLACKBOT"
				if !model.userIsAssigned(user.id)
					peopleToAssign.push(user.toJSON())
			)###

			return peopleToAssign

		handleClickForModelAndTaskCard: (e, model, taskCard) ->
			return if !localStorage.getItem("EnableThreadedConversations")
			if model.isSubtask()
				actions = []
				if model.get("completionDate")
					actions.push({name: "Uncomplete", icon: "quickBarNow", action: "uncomplete"})
				actions.push({name: "Edit", icon: "dragMenuMove", action: "edit"})
				actions.push({name: "Delete", icon: "navbarDelete", action: "delete"})

				swipy.modalVC.presentActionList(actions, {centerX: false, centerY: false, left: e.pageX, top: e.pageY}, (result) ->
					if result is "edit"
						taskCard.find(".input-action-title").attr("contentEditable", true).focus()
					if result is "uncomplete"
						model.scheduleTask()
					if result is "delete"
						model.deleteTask()
				)
				return
			if model.get("selected") or e.metaKey or e.ctrlKey
				model.save("selected", !model.get("selected"))
			else if taskCard.hasClass 'task-item'
				@editMode = true
				if @isMyTasks
					swipy.router.navigate("tasks/"+model.id, {trigger: true})
				else
					swipy.router.navigate("task/"+model.id, {trigger: true})
				#
		###
			TaskList Datasource
		###

		# TaskList asking for number of sections
		taskListNumberOfSections: ( taskList ) ->
			@sortAndGroupCollection(taskList.toggleCompleted)

			return @groupedTasks.length

		sortAndGroupCollection: (toggleCompleted) ->
			@groupedTasks = []

			if @delegate? and _.isFunction(@delegate.taskHandlerSortAndGroupCollection)
				@groupedTasks = @delegate.taskHandlerSortAndGroupCollection( @, @collection, toggleCompleted )
			else
				@groupedTasks = [ { "leftTitle": null, "rightTitle": null, "tasks": @collection.models }]

			return @groupedTasks

		taskListDataForSection: ( taskList, section ) ->
			if !@collection?
				throw new Error("TaskHandler: must loadSubcollection before loading TaskList")

			return null if !@groupedTasks or !@groupedTasks.length

			models = @groupedTasks[ (section-1) ].tasks

			if @listSortAttribute? and @listSortAttribute
				newOnTop = true
				if @newOnBottom
					newOnTop = false
				if !@groupedTasks[ (section-1) ].dontSort? or !@groupedTasks[ (section-1) ].dontSort
					@groupedTasks[ (section-1) ].tasks = @sortTasksAndSetOrder(models, newOnTop)

			# Check filter for limitations
			return @groupedTasks[ (section-1) ]



		# Sort task and fix order of tasks based on the listSortAttribute provided
		sortTasksAndSetOrder: (todos, newOnTop) ->
			defaultOrderVal = -1
			sortedTodoArray = []
			self = @
			# First group tasks into already ordered or not yet ordered (new tasks or moved from schedule etc.)
			groupedItems = _.groupBy( todos, (m) ->
				if m.has(self.listSortAttribute) and m.get(self.listSortAttribute) > defaultOrderVal then "ordered" else "unordered"
			)

			# If any unordered exists - sort them after either schedule or createdAt time (newest first)
			if groupedItems.unordered?
				unorderedItems = _.sortBy( groupedItems.unordered, (m) ->
					schedule = m.get("schedule")
					if !schedule
						if m.get("createdAt")
							return -m.get("createdAt").getTime()
					else
						-schedule.getTime()
				)
				sortedTodoArray = unorderedItems

			# After the grouping and ordering, concat the two groups in the right order based on new ones should be on top or bottom
			if groupedItems.ordered?
				orderedItems = _.sortBy( groupedItems.ordered , (m) -> m.get self.listSortAttribute )
				sortedTodoArray = if newOnTop then sortedTodoArray.concat orderedItems else orderedItems.concat sortedTodoArray

			# Loop through all and set the order values
			orderNumber = 0
			for m in sortedTodoArray
				if !m.has(@listSortAttribute) or m.get(@listSortAttribute) isnt orderNumber
					m.updateOrder @listSortAttribute, orderNumber
				orderNumber++

			return sortedTodoArray

		destroy: ->
			@delegate = null
			@collection?.off(null, null, @)
			@collection?.reset(null)
			@collection = null
