define ["js/model/sync/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Member"
		idAttribute: "objectId"
		attrWhitelist: [ "username", "fullName" ]
		defaults: { name: "", deleted: no }
		initialize: ->
			if @get("objectId") is Parse.User.current().id
				@save("me",true)				
		save: ->
			shouldSync = BaseModel.prototype.handleForSync.apply @ , arguments
			Backbone.Model.prototype.save.apply @ , arguments
			if shouldSync
				BaseModel.prototype.doSync.apply @ , []
		updateFromServerObj: ( obj ) ->
			BaseModel.prototype.updateFromServerObj.apply @, arguments
			@save "username", obj.username if obj.username?
			@save "fullName", obj.fullName if obj.fullName?
			@save "organisationId", obj.organisationId if obj.organisationId?
			BaseModel.prototype.doSync.apply( @ )