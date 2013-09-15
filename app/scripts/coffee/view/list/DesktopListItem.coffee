define ["view/list/BaseListItem"], (BaseListItemView) ->
	BaseListItemView.extend
		events: 
			"click": "toggleSelected"
			"mouseenter .todo-content": "onHover"
			"mouseleave .todo-content": "onHover"
		init: ->
			_.bindAll( @, "onHover", "onMouseMove", "onHoverComplete", "onHoverSchedule", "onUnhoverComplete", "onUnhoverSchedule" )
			
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
			@$el.on( "mousemove", @onMouseMove )
		stopTrackingMouse: ->
			@$el.off "mousemove"
			@isHoveringComplete = @isHoveringSchedule = false	
		onHover: (e) ->
			if e.type is "mouseenter" then @trackMouse()
			else if e.type is "mouseleave" then @stopTrackingMouse()
		onMouseMove: (e) ->
			# Ignore move events from sub nodes
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
			noTodosAreSelected = !window.app.todos.any (model) -> model.get("selected")
			
			if noTodosAreSelected 
				if target is @cid
					console.log "Hover: Complete (None selected)"
			
			# Else check if todo is selected
			else if @model.get( "selected" )
				console.log "Hover: Complete"
		onHoverSchedule: (target) ->
			noTodosAreSelected = !window.app.todos.any (model) -> model.get("selected")
			
			if noTodosAreSelected 
				if target is @cid
					console.log "Hover: Schedule (None selected)"
			
			# Else check if todo is selected
			else if @model.get( "selected" )
				console.log "Hover: Schedule"
		onUnhoverComplete: (target) ->
			noTodosAreSelected = !window.app.todos.any (model) -> model.get("selected")
			
			if noTodosAreSelected 
				if target is @cid
					console.log "Unhover: Complete (None selected)"
			
			# Else check if todo is selected
			else if @model.get( "selected" )
				console.log "Unhover: Complete"
		onUnhoverSchedule: (target) ->
			noTodosAreSelected = !window.app.todos.any (model) -> model.get("selected")
			
			if noTodosAreSelected 
				if target is @cid
					console.log "Unhover: Schedule (None selected)"
			
			# Else check if todo is selected
			else if @model.get( "selected" )
				console.log "Unhover: Schedule"

		customCleanUp: ->
			$(window).off()
			@stopTrackingMouse()