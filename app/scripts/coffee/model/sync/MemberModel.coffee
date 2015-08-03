define ["js/model/sync/BaseModel"], (BaseModel) ->
	BaseModel.extend
		className: "Member"
		attrWhitelist: [ "username", "fullName", "organisationId", "profileImageURL" ]
		initialize: ->
			if @get("objectId") is Parse.User.current().id
				@save("me",true)