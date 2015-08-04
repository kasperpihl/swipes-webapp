define ["js/model/sync/BaseModel", "js/utility/TimeUtility"], (BaseModel, TimeUtility) ->
	BaseModel.extend
		className: "Message"
		attrWhitelist: [ "message", "toUserId", "projectLocalId", "timestamp" ]
		defaults: { message: "", toUserId: null, projectLocalId: null  }
		initialize: ->
			@timeUtil = new TimeUtility()
			if !@get("timestamp")
				@set("localCreatedAt",new Date(),{localSync: true})
			@setTimeStr()
			@on "change:timestamp", =>
				@setTimeStr()
			@handleLikes()
			@on "change:likes", =>
				@handleLikes()
			@setRestrictedForMe()
			@set("unread",true) if @get("userId") isnt Parse.User.current().id
		getUnixTimestamp: ->
			return new Date(@get("timestamp")).getTime()/1000 if @get("timestamp")
			return @get("localCreatedAt").getTime()/1000
		like: ->
			currentLikes = @get "likes"
			userId = Parse.User.current().id
			if !currentLikes
				currentLikes = []

			index = _.indexOf( currentLikes, userId )
			if index isnt -1
				currentLikes.splice(index, 1)
			else
				currentLikes.push(userId)
			@set("likes": null)
			@save {"likes": currentLikes}, {sync:true}
		handleLikes: ->
			currentLikes = @get "likes"
			if !currentLikes
				currentLikes = []
			userId = Parse.User.current().id
			index = _.indexOf( currentLikes, userId )
			@set("likedByMe", (index isnt -1))
			@set("numberOfLikes", currentLikes.length)
		setRestrictedForMe: ->
			if @get("toUserId")
				if @get("toUserId") isnt Parse.User.current().id and @get("userId") isnt Parse.User.current().id
					@set("restrictedForMe",true)
		setTimeStr: ->
			timestamp = @get "timestamp"
			if !timestamp then return @set( "timeStr", undefined )

			# We have a schedule set, update timeStr prop
			@set( "timeStr", @timeUtil.getTimeStr(timestamp) )