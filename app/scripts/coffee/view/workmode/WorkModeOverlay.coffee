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

			
			@render()
			@startTimer()
		startTimer: ->
			@timeUtil = new TimeUtility()
			@endTime = @options.workModel.get("endTime")
			@runTimer()
    		
		runTimer: ->
			@calculateTimeToEnd()
			milli = 1000 - new Date().getMilliseconds()
			console.log milli
			setTimeout(@runTimer, Math.max(milli, 1))
		calculateTimeToEnd: ->
			diff = Math.ceil((@endTime.getTime() - new Date().getTime())/1000,10)
			timeString = @timeUtil.getFormattedTimeFromSeconds(diff)
			console.log timeString
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