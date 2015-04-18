define ["underscore", "js/view/Overlay", "text!templates/work-mode-overlay.html","js/utility/TimeUtility"], (_, Overlay, WorkModeTmpl, TimeUtility) ->
	Overlay.extend
		className: 'overlay work-mode'
		events:
			"click .done" : "render"
		initialize: ->
			_.bindAll( @ , "runTimer" )
			if arguments[ 0 ]
				@options = arguments[ 0 ]
			Overlay::initialize.apply( @, arguments )
			@showClassName = "work-mode-open"
			@hideClassName = "hide-work-mode"

			@model = @options.workModel

			@render()
			@startTimer()
		startTimer: ->
			@timeUtil = new TimeUtility()

			@endTime = @options.workModel.get("endTime")
			@runTimer()
    		
		runTimer: ->
			@calculateTimeToEnd()
			milli = 1000 - new Date().getMilliseconds()
			setTimeout(@runTimer, Math.max(milli, 1))
		calculateTimeToEnd: ->
			diff = @model.secondsLeft()
			timeString = @timeUtil.getFormattedTimeFromSeconds(diff)
			@renderTime timeString 
		setTemplate: ->
			@template = _.template WorkModeTmpl
		renderTime: (timeString) ->
			@$el.find(".time-label").html timeString
		render: () ->
			@$el.html @template( { title: @options.taskModel.get("title") } )
			if not $("body").find(".overlay.work-mode").length
				$("body").append @$el

			@show()
			return @
		afterShow: ->
			swipy.shortcuts.lock()
		afterHide: ->
			swipy.shortcuts.unlock()


### Model
	startTime
	endTime
###