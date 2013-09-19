define ["jquery", "gsap", "gsap-draggable"], ($, TweenLite, Draggable) ->
	class ListSortController
		constructor: (@container, @views) ->
			@rowHeight = @views[0].$el.height()
			@disableNativeClickHandlers()
			@init()
		disableNativeClickHandlers: ->
			for view in @views
				console.log "Disable native click event"
		init: ->
			if @draggables? then @destroy()

			self = @
			
			dragOpts = 
				type: "y"
				bounds: @container
				edgeResistance: 0.75
				throwProps: yes
				snap: 
					y: (endValue) ->
						# Snap to closest row
						return Math.max( @minY, Math.min( @maxY, Math.round( endValue / self.rowHeight ) * self.rowHeight ) );
				onClick: (view, allViews) ->
					console.log "Clicked ", view
				onDragStart: ->
					TweenLite.to( @target, 0.15, { scale: 1.1, boxShadow: "0px 0px 15px 1px rgba(0,0,0,0.2)", } );
				onDrag: (view, allViews) ->
					console.log "Dragged ", @
				onDragEnd: (view, allViews) ->
					TweenLite.to( @target, 0.25, { scale: 1, boxShadow: "none", } );
			
			@draggables = []
			for view in @views
				dragOpts.onClickParams = dragOpts.onDragParams = [view, @views]

				dragOpts.trigger = view.$el.find ".todo-content"
				@draggables.push Draggable.create( view.$el, dragOpts )
			
		destroy: ->
			draggable.disable() for draggable in @draggables
			@draggables = null