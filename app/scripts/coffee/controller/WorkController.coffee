define ["underscore", "js/view/workmode/WorkModeOverlay", "js/model/WorkModel"], (_, WorkModeOverlay, WorkModel) ->
	class WorkController
		constructor: ->
			Backbone.on( "new-work-mode", @setWorkModel, @)
		setWorkModel: (model, minutes) ->
			console.log model
			console.log minutes
			startTime = new Date()
			endTime = new Date(startTime.getTime() + minutes * 60000);
			workModel = new WorkModel()
			workModel.set("startTime", startTime )
			workModel.set("endTime", endTime )
			workModel.set("taskLocalId", model.id )
			@openWorkMode( model, workModel )
		openWorkMode: (taskModel, workModel) ->
			@workMode = new WorkModeOverlay( { taskModel: taskModel, workModel: workModel })