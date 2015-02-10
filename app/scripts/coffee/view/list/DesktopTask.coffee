define ["underscore", "js/view/list/BaseTask"], (_, BaseTaskView) ->
	BaseTaskView.extend
		events:
			"mouseenter": "trackMouse"
			"mouseleave": "stopTrackingMouse"
		init: ->
			@throttledOnMouseMove = _.throttle( @onMouseMove, 250 )
			@bouncedHover = _.debounce(@onHoverTask, 150)
			_.bindAll( @, "setBounds", "onHoverTask", "onUnhoverTask", "bouncedHover" )

			@listenTo( Backbone, "hover-task", @onHoverTask )
			@listenTo( Backbone, "unhover-task", @onUnhoverTask )

		getMousePos: (mouseX) ->
			if !@bounds then @setBounds()
			Math.round ( ( mouseX - @bounds.left ) / @bounds.width ) * 100
		trackMouse: ->
			@isHovering = true
			@bouncedHover()
			#@allowThrottledMoveHandler = yes
			#@$el.on( "mousemove", @throttledOnMouseMove )
		stopTrackingMouse: ->
			@isHovering = false
			@onUnhoverTask( @cid )
			###@$el.off "mousemove"
			@isHoveringComplete = @isHoveringSchedule = false

			# Because mouse-move is throttled, we need to catch that throttled function
			@allowThrottledMoveHandler = no

			Backbone.trigger( "unhover-complete", @.cid )
			Backbone.trigger( "unhover-schedule", @.cid )###
		###onMouseMove: (e) ->
			return unless @allowThrottledMoveHandler
			@determineUserIntent @getMousePos e.pageX
		determineUserIntent: (mousePos) ->
			console.log mousePos
			if mousePos <= 15 and not @isHoveringComplete
				Backbone.trigger( "hover-complete", @.cid )
				@isHoveringComplete = true

			else if mousePos > 15 and @isHoveringComplete
				Backbone.trigger( "unhover-complete", @.cid )
				@isHoveringComplete = false

			if mousePos >= 85 and not @isHoveringSchedule
				Backbone.trigger( "hover-schedule", @.cid )
				@isHoveringSchedule = true

			else if mousePos < 85 and @isHoveringSchedule
				Backbone.trigger( "unhover-schedule", @.cid )
				@isHoveringSchedule = false
		###
		onHoverTask: (target) ->
			if @isHovering
				@$el.addClass "hover"
			#if @model.get( "selected" ) or target is @cid
				

		onUnhoverTask: (target) ->
			@$el.removeClass "hover"
			#if @model.get( "selected" ) or target is @cid
				


		render: ->
			if @model.get "animateIn"
				@$el.addClass "animate-in"
				@model.unset "animateIn"

			BaseTaskView::render.apply( @, arguments )

		customCleanUp: ->
			@stopTrackingMouse()