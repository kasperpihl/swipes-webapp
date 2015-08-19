define ["underscore", "js/utility/TimeUtility"], (_, TimeUtility) ->
	Backbone.Model.extend
		className: "Bot"
		initialize: ->
			@timeUtil = new TimeUtility()
			@setTimeStr()
			@on "change:ts", =>
				@setTimeStr()
		setTimeStr: ->
			timestamp = new Date(parseInt(@get("ts")))
			if !timestamp then return @set( "timeStr", undefined )

			# We have a schedule set, update timeStr prop
			@set( "timeStr", @timeUtil.getTimeStr(timestamp) )