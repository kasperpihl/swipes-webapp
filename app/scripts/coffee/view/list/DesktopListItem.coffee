define ["underscore", "view/list/BaseListItem"], (_, BaseListItemView) ->
	BaseListItemView.extend
		events: 
			"click": "toggleSelected"
			"mouseenter .todo-content": "onHover"
			"mouseleave .todo-content": "onHover"
		init: ->
			@throttledOnMouseMove = _.throttle( @onMouseMove, 250 )
			
			_.bindAll( @, "onHover", "onMouseMove", "throttledOnMouseMove", "onHoverComplete", "onHoverSchedule", "onUnhoverComplete", "onUnhoverSchedule" )
			

			@width = @$el.width()
			@x = @$el.offset().left
			
			$(window).on "resize", => 
				@width = @$el.width()
				@x = @$el.offset().left

			Backbone.on( "hover-complete", @onHoverComplete )
			Backbone.on( "hover-schedule", @onHoverSchedule )
			Backbone.on( "unhover-complete", @onUnhoverComplete )
			Backbone.on( "unhover-schedule", @onUnhoverSchedule )

		toggleSelected: ->
			currentlySelected = @model.get( "selected" ) or false
			@model.set( "selected", !currentlySelected )
		getMousePos: (mouseX) ->
			mouseX = mouseX - @x # Adjust for view positoin on the page
			Math.round ( mouseX / @width ) * 100
		trackMouse: ->
			@$el.on( "mousemove", @throttledOnMouseMove )
		stopTrackingMouse: ->
			@$el.off "mousemove"
			@isHoveringComplete = @isHoveringSchedule = false	


		onHover: (e) ->
			if e.type is "mouseenter" then @trackMouse()
			else if e.type is "mouseleave" then @stopTrackingMouse()
		onMouseMove: (e) ->
			console.log "Mouse move"

			# If we have any todos selected, but the hover target isnt
			# selected, just ignore any movement
			if window.app.todos.any( (model) -> model.get("selected") )
				if not @model.get "selected"
					return false

			mousePos = @getMousePos e.pageX

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
			if @model.get( "selected" ) or target is @cid
				console.log "Hover: Complete"
		onHoverSchedule: (target) ->
			if @model.get( "selected" ) or target is @cid
				console.log "Hover: Schedule"
		onUnhoverComplete: (target) ->
			if @model.get( "selected" ) or target is @cid
				console.log "Unhover: Complete"
		onUnhoverSchedule: (target) ->
			if @model.get( "selected" ) or target is @cid
				console.log "Unhover: Schedule"

		customCleanUp: ->
			$(window).off()
			@stopTrackingMouse()