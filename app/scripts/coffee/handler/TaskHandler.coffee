###
	Get all the tasks from project, team member or personal (subcollection w/ filter)
	Receive action from TaskList about a drag/drop hit and handle the request
		Find out who's the sender, where does it want to go, and what actions would be available
	Receive select/unselect from TaskList
###
define ["underscore", "js/view/modal/AssignModal"], (_, AssignModal) ->
	class TaskHandler
		constructor: ->
			@bouncedReloadWithEvent = _.debounce( @reloadWithEvent, 5 )
		loadCollection: (collection) ->
			@collection = collection
			@collection.on("add remove reset change:order change:projectOrder change:schedule", @bouncedReloadWithEvent, @ )
			Backbone.on("show-assign", @didPressAssign, @)
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
					if $el.hasClass("task-item")
						draggedId = "#" + $el.attr("id")
			else if e.originalTarget?
				currentTarget = e.originalTarget
				for num in [1..10]
					if currentTarget? and currentTarget
						if _.indexOf(currentTarget.classList, "task-item") isnt -1
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

			return [] if !draggedTask?

			draggedTask.set("selected",true) 
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
			@handleClickForModelAndTaskCard(e, model, taskCard, dragHandler)
			false

		### 
			TaskCard Delegate
		###
		taskCardDidComplete: (taskCard) ->
			model = taskCard.model
			model.completeTask()
			Backbone.trigger("reload/taskhandler")
		didPressAssign: (model, e) ->
			assignModal = new AssignModal({model: model})
			assignModal.dataSource = @
			assignModal.render()
			assignModal.presentModal({ left: e.clientX, top:e.clientY+10, centerY: false })
			
		assignModalPeopleToAssign: (assignModal) ->
			peopleToAssign = []
			model = assignModal.model
			me = swipy.slackCollections.users.me()
			if me? and !model.userIsAssigned(me.id)
				peopleToAssign.push(me.toJSON())
				
			swipy.slackCollections.users.each( (user) =>
				return if user.id is me.id or user.get("deleted") or user.get("is_bot") or user.id is "USLACKBOT"
				if !model.userIsAssigned(user.id)
					peopleToAssign.push(user.toJSON())
			)

			return peopleToAssign

		handleClickForModelAndTaskCard: (e, model, taskCard, dragHandler) ->
			if model.get("selected") or e.metaKey or e.ctrlKey
				model.save("selected", !model.get("selected"))
			else
				shouldShow = !taskCard.hasClass("editMode")
				console.log "shouldShow", shouldShow
				if shouldShow or $(e.target).hasClass('main-info-container')
					$(".editMode").removeClass("editMode")
				if shouldShow
					#@editTask = new EditTask({model: model})
					#@editTask.render()
					@editMode = true
					Backbone.trigger("edit/task", model)
					#taskCard.find(".expanding").html @editTask.el
					#taskCard.addClass("editMode")
					
		### 
			TaskList Datasource
		###

		# TaskList asking for number of sections
		taskListNumberOfSections: ( taskList ) ->
			@sortAndGroupCollection()
			return @groupedTasks.length
		sortAndGroupCollection: ->
			@groupedTasks = []
			if @delegate? and _.isFunction(@delegate.taskHandlerSortAndGroupCollection)
				@groupedTasks = @delegate.taskHandlerSortAndGroupCollection( @, @collection )
			else
				@groupedTasks = [ { "leftTitle": null, "rightTitle": null, "tasks": @collection.models }]
			return @groupedTasks
		taskListDataForSection: ( taskList, section ) ->
			if !@collection?
				throw new Error("TaskHandler: must loadSubcollection before loading TaskList")
				
			return null if !@groupedTasks or !@groupedTasks.length
			models = @groupedTasks[ (section-1) ].tasks
			if @listSortAttribute? and @listSortAttribute
				if !@groupedTasks[ (section-1) ].dontSort? or !@groupedTasks[ (section-1) ].dontSort
					@groupedTasks[ (section-1) ].tasks = @sortTasksAndSetOrder(models, true)
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