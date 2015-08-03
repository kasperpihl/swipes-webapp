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
			@setRestrictedForMe()
			@set("unread",true) if @get("userId") isnt Parse.User.current().id
		setRestrictedForMe: ->
			if @get("toUserId")
				if @get("toUserId") isnt Parse.User.current().id and @get("userId") isnt Parse.User.current().id
					@set("restrictedForMe",true)
		setTimeStr: ->
			timestamp = @get "timestamp"
			if !timestamp then return @set( "timeStr", undefined )

			# We have a schedule set, update timeStr prop
			@set( "timeStr", @timeUtil.getTimeStr(timestamp) )