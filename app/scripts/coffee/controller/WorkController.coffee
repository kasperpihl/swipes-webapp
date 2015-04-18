define ["underscore", "js/view/workmode/WorkModeOverlay", "js/model/WorkModel"], (_, WorkModeOverlay, WorkModel) ->
	class WorkController
		constructor: (collection) ->
			Backbone.on( "new-work-mode", @setWorkModel, @)
			current = swipy.workSessions.currentWorkTask()
			if current
				swipy.router.navigate("work/"+current.get("taskLocalId"),true)
			console.log current
		setWorkModel: (model, minutes) ->
			startTime = new Date()
			endTime = new Date(startTime.getTime() + minutes * 60000);
			workModel = new WorkModel()
			workModel.set("startTime", startTime )
			workModel.set("endTime", endTime )
			workModel.set("taskLocalId", model.id )
			swipy.workSessions.add workModel
			workModel.save()
			@openWorkMode( model, workModel )
		openWorkMode: (taskModel, workModel) ->
			@workMode = new WorkModeOverlay( { taskModel: taskModel, workModel: workModel })