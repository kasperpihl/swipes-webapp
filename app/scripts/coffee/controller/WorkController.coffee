define ["underscore", "js/view/workmode/WorkModeOverlay", "js/model/WorkModel"], (_, WorkModeOverlay, WorkModel) ->
	class WorkController
		constructor: (collection) ->
			Backbone.on( "new-work-mode", @setWorkModel, @)
			Backbone.on( "work-mode", @openWorkFromRouter, @ )
			_.bindAll( @, "checkForWork" )
			@bouncedCheckForWork = _.debounce(@checkForWork, 50)
			swipy.collections.workSessions.on( "add change:completionTime change:cancelTime change:hasChosenCompleted", @bouncedCheckForWork )
			@isWorking = false
		checkForWork: ->
			currentWork = swipy.collections.workSessions.currentWorkTask()
			if currentWork and !@isWorking
				swipy.router.navigate("work", true)
			else if @isWorking and !currentWork
				@workMode?.destroy()
				@isWorking = false
				swipy.router.openLastMainView(false)
		openWorkFromRouter: ->
			currentWork = swipy.collections.workSessions.currentWorkTask()
			if currentWork
				task = swipy.collections.todos.get(currentWork.get("taskLocalId"))
				if task
					@isWorking = true
					return @openWorkMode( task, currentWork )
			@isWorking = false
			swipy.router.navigate("tasks/now", true)
		setWorkModel: (model, minutes) ->
			startTime = new Date()
			endTime = new Date(startTime.getTime() + minutes * 60000);
			workModel = new WorkModel()
			workModel.set("startTime", startTime )
			workModel.set("endTime", endTime )
			workModel.set("taskLocalId", model.id )
			swipy.collections.workSessions.add workModel
			workModel.save()
			#@openWorkMode( model, workModel )
		openWorkMode: (taskModel, workModel) ->
			@workMode = new WorkModeOverlay( { taskModel: taskModel, workModel: workModel })