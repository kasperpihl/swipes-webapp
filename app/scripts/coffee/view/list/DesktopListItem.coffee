define ["underscore", "view/list/BaseListItem"], (_, BaseListItemView) ->
	BaseListItemView.extend
		events: 
			"click": "toggleSelected"
			"mouseenter": "trackMouse"
			"mouseleave": "stopTrackingMouse"
		init: ->
			@throttledOnMouseMove = _.throttle( @onMouseMove, 250 )
			
			_.bindAll( @, "setBounds", "onMouseMove", "throttledOnMouseMove", "onHoverComplete", "onHoverSchedule", "onUnhoverComplete", "onUnhoverSchedule" )
			
			$(window).on "resize", @setBounds


			@listenTo( Backbone, "hover-complete", @onHoverComplete )
			@listenTo( Backbone, "hover-schedule", @onHoverSchedule )
			@listenTo( Backbone, "unhover-complete", @onUnhoverComplete )
			@listenTo( Backbone, "unhover-schedule", @onUnhoverSchedule )

		toggleSelected: ->
			currentlySelected = @model.get( "selected" ) or false
			@model.set( "selected", !currentlySelected )
		setBounds: ->
			@bounds = @el.getClientRects()[0]
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
			if mousePos <= 15 and @isHoveringComplete isnt true
				Backbone.trigger( "hover-complete", @.cid )
				@isHoveringComplete = true
			
			else if mousePos > 15 and @isHoveringComplete
				Backbone.trigger( "unhover-complete", @.cid )
				@isHoveringComplete = false

			if mousePos >= 85 and @isHoveringSchedule isnt true
				Backbone.trigger( "hover-schedule", @.cid )
				@isHoveringSchedule = true

			else if mousePos < 85 and @isHoveringSchedule
				Backbone.trigger( "unhover-schedule", @.cid )
				@isHoveringSchedule = false
		onHoverComplete: (target) ->
			@$el.addClass "hover-complete" if @model.get( "selected" ) or target is @cid
		onHoverSchedule: (target) ->
			@$el.addClass "hover-schedule" if @model.get( "selected" ) or target is @cid
		onUnhoverComplete: (target) ->
			@$el.removeClass "hover-complete" if @model.get( "selected" ) or target is @cid
		onUnhoverSchedule: (target) ->
			@$el.removeClass "hover-schedule" if @model.get( "selected" ) or target is @cid
		customCleanUp: ->
			$(window).off()
			@stopTrackingMouse()