define ["underscore", "js/view/list/BaseTask"], (_, BaseTaskView) ->
	BaseTaskView.extend
		events:
			"mouseenter": "trackMouse"
			"mouseleave": "stopTrackingMouse"
			"drag": "onDrag"
		init: ->
			@throttledOnMouseMove = _.throttle( @onMouseMove, 250 )
			@bouncedHover = _.debounce(@onHoverTask, 150)
			@bouncedTrigger = _.debounce(@triggerDrag, 5)
			_.bindAll( @, "setBounds", "onHoverTask", "onUnhoverTask", "bouncedHover", "onMouseDown", "onMouseUp", "onMouseMove" )

			@listenTo( Backbone, "hover-task", @onHoverTask )
			@listenTo( Backbone, "unhover-task", @onUnhoverTask )
			@$el.mousedown( @onMouseDown )
			@$el.mouseup( @onMouseUp )
		triggerDrag: (e) ->
			Backbone.trigger("drag-model", @model, e )
			@isDragging = false
		onMouseDown: (e) ->
			@screenY = e.screenY
			$(window).mousemove( @onMouseMove )
		onMouseMove: (e) ->
			threshold = 10
			return if @isDragging
			if Math.abs(e.screenY - @screenY) > threshold
				@isDragging = true
				@triggerDrag(e)
				$(window).unbind("mousemove")
		onMouseUp: (e) ->
			@screenY = 0
			@isDragging = false
			$(window).unbind("mousemove")
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