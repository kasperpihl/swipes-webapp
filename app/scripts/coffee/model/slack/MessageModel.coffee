define ["underscore", "js/utility/TimeUtility"], (_, TimeUtility) ->
	Backbone.Model.extend
		className: "Message"
		idAttribute: "ts"
		initialize: ->
			@timeUtil = new TimeUtility()
			@setTimeStr()
			@on "change:ts", =>
				@setTimeStr()
		setTimeStr: ->
			timestamp = new Date(parseInt(@get("ts"))*1000)
			if !timestamp then return @set( "timeStr", undefined )

			# We have a schedule set, update timeStr prop
			@save( "timeStr", @timeUtil.getTimeStr(timestamp) )