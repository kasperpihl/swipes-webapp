define ["js/model/sync/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Message"
		idAttribute: "objectId"
		attrWhitelist: [ "message", "toUserId", "projectLocalId" ]
		defaults: { message: "", toUserId: null, projectLocalId: null  }
		initialize: ->