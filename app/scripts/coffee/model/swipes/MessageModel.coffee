define ["underscore", "js/utility/TimeUtility"], (_, TimeUtility) ->
	Backbone.Model.extend
		className: "Message"
		idAttribute: "ts"
		initialize: ->
			@timeUtil = new TimeUtility()
			@setTimeStr()
			@on "change:ts", =>
				@setTimeStr()
		getText: ->
			return @get("text") if @get("text")
			return @get("attachments")[0].fallback if @get("attachments") and @get("attachments").length
			return "No text found" 
		setTimeStr: ->
			timestamp = new Date(parseInt(@get("ts"))*1000)
			if !timestamp then return @set( "timeStr", undefined )

			# We have a schedule set, update timeStr prop
			@save( "timeStr", @timeUtil.getTimeStr(timestamp) )