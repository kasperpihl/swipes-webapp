define ["js/model/sync/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Message"
		attrWhitelist: [ "message", "toUserId", "projectLocalId" ]
		defaults: { message: "", toUserId: null, projectLocalId: null  }
		initialize: ->