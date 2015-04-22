define ["underscore", "js/view/Overlay", "text!templates/work-mode-overlay.html","js/utility/TimeUtility"], (_, Overlay, WorkModeTmpl, TimeUtility) ->
	Overlay.extend
		className: 'overlay work-mode'
		events:
			"click .back-button" : "back"
			"click .action-complete": "complete"
		initialize: ->
			_.bindAll( @ , "runTimer" )
			if arguments[ 0 ]
				@options = arguments[ 0 ]
			Overlay::initialize.apply( @, arguments )
			@showClassName = "work-mode-open"
			@hideClassName = "hide-work-mode"

			@model = @options.workModel
			@taskModel = @options.taskModel

			@render()
			@startTimer()
		complete: ->
			@taskModel.completeTask()
			@model.save("completionTime", new Date())
		back: ->
			shouldGoBack = confirm "Are you sure you want to cancel the work session?"
			if shouldGoBack
				@model.save("cancelTime",new Date())
		startTimer: ->
			@timeUtil = new TimeUtility()

			@endTime = @options.workModel.get("endTime")
			@runTimer()
    		
		runTimer: ->
			#snd = new Audio("file.wav")
			#snd.play()
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
			self = @
			require ["bootstrapTooltip"],() ->
				self.$el.find('[data-toggle="tooltip"]').tooltip({delay:{show:300,hide:0}})

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