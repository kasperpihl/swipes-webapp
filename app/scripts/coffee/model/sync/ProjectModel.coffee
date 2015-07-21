define ["js/model/sync/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Project"
		idAttribute: "objectId"
		attrWhitelist: [ "name", "ownerId" ]
		defaults: { name: "", deleted: no }
		save: ->
			shouldSync = BaseModel.prototype.handleForSync.apply @ , arguments
			Backbone.Model.prototype.save.apply @ , arguments
			if shouldSync
				BaseModel.prototype.doSync.apply @ , []
		updateFromServerObj: ( obj ) ->
			BaseModel.prototype.updateFromServerObj.apply @, arguments
			@save "name", obj.name if obj.name?
			@save "ownerId", obj.ownerId if obj.ownerId?
			BaseModel.prototype.doSync.apply( @ )