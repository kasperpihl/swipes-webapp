define ["js/model/sync/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Project"
		idAttribute: "objectId"
		attrWhitelist: [ "name" ]
		defaults: { name: "", deleted: no }
		save: ->
			shouldSync = BaseModel.prototype.handleForSync.apply @ , arguments
			Backbone.Model.prototype.save.apply @ , arguments
			if shouldSync
				BaseModel.prototype.doSync.apply @ , []
		updateFromServerObj: ( obj ) ->
			BaseModel.prototype.updateFromServerObj.apply @, arguments
			@save "name", obj.name if obj.name?
			BaseModel.prototype.doSync.apply( @ )