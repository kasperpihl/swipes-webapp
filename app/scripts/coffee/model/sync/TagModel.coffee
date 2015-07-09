define ["js/model/sync/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Tag"
		idAttribute: "objectId"
		attrWhitelist: [ "title" ]
		defaults: { title: "", deleted: no }
		save: ->
			shouldSync = BaseModel.prototype.handleForSync.apply @ , arguments
			Backbone.Model.prototype.save.apply @ , arguments
			if shouldSync
				BaseModel.prototype.doSync.apply @ , []
		updateFromServerObj: ( obj ) ->
			BaseModel.prototype.updateFromServerObj.apply @, arguments
			@save "title", obj.title if obj.title?
			BaseModel.prototype.doSync.apply( @ )