define ["js/model/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Tag"
		idAttribute: "objectId"
		attrWhitelist: [ "title" ]
		defaults: { title: "", deleted: no }
		set: ->
			BaseModel.prototype.handleForSync.apply( @ , arguments )
			Backbone.Model.prototype.set.apply( @ , arguments )
		deleteTag: ->
			@set "deleted", yes, { sync: true }
		updateFromServerObj: ( obj ) ->
			BaseModel.prototype.updateFromServerObj.apply @, arguments
			@set "title", obj.title if obj.title?