define ["js/model/sync/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Member"
		idAttribute: "objectId"
		attrWhitelist: [ "username", "fullName", "organisationId" ]
		initialize: ->
			if @get("objectId") is Parse.User.current().id
				@save("me",true)				