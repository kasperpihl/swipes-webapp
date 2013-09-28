define ["underscore", "view/list/BaseTask"], (_, BaseTaskView) ->
	BaseTaskView.extend
		events:
			"mouseenter": "trackMouse"
			"mouseleave": "stopTrackingMouse"
		init: ->
			@throttledOnMouseMove = _.throttle( @onMouseMove, 250 )
			
			_.bindAll( @, "setBounds", "onMouseMove", "throttledOnMouseMove", "onHoverComplete", "onHoverSchedule", "onUnhoverComplete", "onUnhoverSchedule" )

			@listenTo( Backbone, "hover-complete", @onHoverComplete )
			@listenTo( Backbone, "hover-schedule", @onHoverSchedule )
			@listenTo( Backbone, "unhover-complete", @onUnhoverComplete )
			@listenTo( Backbone, "unhover-schedule", @onUnhoverSchedule )
		
		getMousePos: (mouseX) ->
			if !@bounds then @setBounds()
			Math.round ( ( mouseX - @bounds.left ) / @bounds.width ) * 100
		trackMouse: ->
			@allowThrottledMoveHandler = yes
			@$el.on( "mousemove", @throttledOnMouseMove )
		stopTrackingMouse: ->
			@$el.off "mousemove"
			@isHoveringComplete = @isHoveringSchedule = false	

			# Because mouse-move is throttled, we need to catch that throttled function
			@allowThrottledMoveHandler = no

			Backbone.trigger( "unhover-complete", @.cid )
			Backbone.trigger( "unhover-schedule", @.cid )
		onMouseMove: (e) ->
			return unless @allowThrottledMoveHandler
			@determineUserIntent @getMousePos e.pageX
		determineUserIntent: (mousePos) ->
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
		
		onHoverComplete: (target) ->
			if @model.get( "selected" ) or target is @cid
				@$el.addClass "hover-left" 
		
		onHoverSchedule: (target) ->
			if @model.get( "selected" ) or target is @cid
				@$el.addClass "hover-right"
		
		onUnhoverComplete: (target) ->
			if @model.get( "selected" ) or target is @cid
				@$el.removeClass "hover-left"
		
		onUnhoverSchedule: (target) ->
			if @model.get( "selected" ) or target is @cid
				@$el.removeClass "hover-right"
		
		customCleanUp: ->
			@stopTrackingMouse()