define ["js/model/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Tag"
		idAttribute: "objectId"
		attrWhitelist: [ "title" ]
		defaults: { title: "", deleted: no }
		save: ->
			shouldSync = BaseModel.prototype.handleForSync.apply @ , arguments
			Backbone.Model.prototype.save.apply @ , arguments
			console.log "saving tag"
			if shouldSync
				console.log "syncing tag"
				BaseModel.prototype.doSync.apply @ , []
		updateFromServerObj: ( obj ) ->
			BaseModel.prototype.updateFromServerObj.apply @, arguments
			@save "title", obj.title if obj.title?