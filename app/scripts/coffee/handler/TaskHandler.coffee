###
	Get all the tasks from project, team member or personal (subcollection w/ filter)
	Receive action from TaskList about a drag/drop hit and handle the request
		Find out who's the sender, where does it want to go, and what actions would be available
	Receive select/unselect from TaskList

###
define ["underscore"], (_) ->
	class TaskHandler
		constructor: ->
		loadSubcollection: (filter) ->
			if !_.isFunction(filter)
				throw new Error("TaskHandler loadSubcollection: filter must be a function")
			@collection = swipy.collections.todos.subcollection(
				filter: filter
			)

		### 
			DragHandler Delegate
		###
		dragHandlerDidHit: ( dragHandler, draggedId, hit ) ->
			console.log draggedId, hit
		
		### 
			TaskList Datasource
		###
		tasksForTaskList: ( taskList ) ->
			if !@collection?
				throw new Error("TaskHandler: must loadSubcollection before loading TaskList")
			return @collection.toJSON()