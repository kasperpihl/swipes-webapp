define ["js/model/sync/BaseModel", "js/utility/TimeUtility"], (BaseModel, TimeUtility) ->
	BaseModel.extend
		className: "Message"
		attrWhitelist: [ "message", "toUserId", "projectLocalId", "timestamp" ]
		defaults: { message: "", toUserId: null, projectLocalId: null, timestamp: new Date()  }
		initialize: ->
			@timeUtil = new TimeUtility()
			@setTimeStr()
			@on "change:timestamp", =>
				@setTimeStr()
			@setRestrictedForMe()
		setRestrictedForMe: ->
			if @get("toUserId")
				if @get("toUserId") isnt Parse.User.current().id and @get("userId") isnt Parse.User.current()
					@set("restrictedForMe",true)
		setTimeStr: ->
			timestamp = @get "timestamp"
			if !timestamp then return @set( "timeStr", undefined )

			# We have a schedule set, update timeStr prop
			@set( "timeStr", @timeUtil.getTimeStr(timestamp) )