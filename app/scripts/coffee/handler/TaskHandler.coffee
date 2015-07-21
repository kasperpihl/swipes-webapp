###
	Get all the tasks from project, team member or personal (subcollection w/ filter)
	Receive action from TaskList about a drag/drop hit and handle the request
		Find out who's the sender, where does it want to go, and what actions would be available
	Receive select/unselect from TaskList
###
define ["underscore"], (_) ->
	class TaskHandler
		constructor: ->
		loadCollection: (collection) ->
			@collection = collection
		taskCollectionIdFromHtmlId: (taskHtmlId) ->
			# #task-
			return if !taskHtmlId or !_.isString(taskHtmlId)
			taskHtmlId.substring(6)
		projectCollectionIdFromHtmlId: (projectHtmlId) ->
			# #sidebar-project-
			return if !projectHtmlId or !_.isString(projectHtmlId)
			projectHtmlId.substring(17)
		memberCollectionIdFromHtmlId: (memberHtmlId) ->
			# #sidebar-member-
			return if !memberHtmlId or !_.isString(memberHtmlId)
			memberHtmlId.substring(16)
		
		###
			DragHandler Delegate
		###
		extraIdsForDragging:( dragHandler, draggedId ) ->
			draggedTask = @collection.get( @taskCollectionIdFromHtmlId(draggedId) )

			return [] if !draggedTask?
			draggedTask.set("selected",true)
			selectedTasks = @collection.getSelected(draggedTask)

			titles = _.invoke(selectedTasks, "get", "title")
			$('.drag-mouse-pointer ul').html ""
			for title in titles
				$('.drag-mouse-pointer ul').append("<li>"+title+"</li>")
			idsToReturn = []
			for task in selectedTasks
				idsToReturn.push("#task-"+task.id)
			idsToReturn
		# Deal with dropped items from DragHandler if true is returned, callback must be called!
		dragHandlerDidHit: ( dragHandler, draggedId, hit, callback ) ->
			draggedTask = @collection.get( @taskCollectionIdFromHtmlId(draggedId) )
			return if !draggedTask?

			selectedTasks = @collection.getSelected( draggedTask )
			console.log hit
			return false if !hit?
			

			if hit.type is "task"
				hitTask = @collection.get( @taskCollectionIdFromHtmlId(hit.target) )
				return if !hitTask?

				if hit.position is "middle"
					
					setTimeout(()->
						callback()
					, 400)
					return true
					#hitTask.addSubtask draggedTask, true
					#Backbone.trigger("reload/handler")
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

					Backbone.trigger("reload/handler")
			else if hit.type is "project"
				targetProject = swipy.collections.projects.get( @projectCollectionIdFromHtmlId(hit.target) )
				return if !targetProject?
				actions = []
				actions.push({name: "Copy to " + targetProject.get("name"), action: "copy"})
				actions.push({name: "Move to " + targetProject.get("name"), action: "move"})
				swipy.modalVC.presentActionList(actions, {centerX: false, centerY: false, left: hit.pointerEvent.x, top: hit.pointerEvent.y, frame:true}, (result) ->
					if result is "move"
						# and update selected tasks as well
						_.invoke(selectedTasks, "save", {"projectLocalId": targetProject.id}, {sync: true} )
						Backbone.trigger("reload/handler")
				)
			else if hit.type is "member"
				memberId = @memberCollectionIdFromHtmlId(hit.target)
				member = swipy.collections.members.get(memberId)
				name = member.get "username"
				actions = []
				actions.push({name: "Assign " + name, action: "copy"})
				actions.push({name: "Copy to " + name, action: "copy"})
				actions.push({name: "Move to " + name , action: "move"})
				swipy.modalVC.presentActionList(actions, {centerX: false, centerY: false, left: hit.pointerEvent.x, top: hit.pointerEvent.y, frame:true}, (result) ->
					console.log result
				)
			false

		sortAndGroupCollection: ->
			@groupedTasks = []
			if @delegate? and _.isFunction(@delegate.taskHandlerSortAndGroupCollection)
				@groupedTasks = @delegate.taskHandlerSortAndGroupCollection( @, @collection )
			else
				@groupedTasks = [ { "leftTitle": null, "rightTitle": null, "tasks": @collection.models }]
			return @groupedTasks
		### 
			TaskCard Delegate
		###
		taskCardDidComplete: (taskCard) ->
			model = taskCard.model
			model.completeTask()
			console.log model.toJSON()
			Backbone.trigger("reload/handler")
		taskCardDidClickAction: (taskCard, e) ->
			
		taskDidClick: (taskCard) ->
			model = taskCard.model
			model.set("selected", !model.get("selected"))
		### 
			TaskList Datasource
		###

		# TaskList asking for number of sections
		taskListNumberOfSections: ( taskList ) ->
			@sortAndGroupCollection()
			return @groupedTasks.length
		taskListLeftTitleForSection: ( taskList, section ) ->
			return @groupedTasks[ (section-1) ].leftTitle
		taskListRightTitleForSection: ( taskList, section ) ->
			return @groupedTasks[ (section-1) ].rightTitle
		
		taskListTasksForSection: ( taskList, section ) ->
			if !@collection?
				throw new Error("TaskHandler: must loadSubcollection before loading TaskList")
			#@collection.fetch()
			models = @groupedTasks[ (section-1) ].tasks

			if @listSortAttribute? and @listSortAttribute
				models = @sortTasksAndSetOrder(models, true)
			# Check filter for limitations
			return models

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
						-m.get("createdAt").getTime()
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