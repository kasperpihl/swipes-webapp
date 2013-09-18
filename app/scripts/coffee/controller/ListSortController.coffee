define ["jquery", "gsap-draggable"], ($, Draggable) ->
	class ListSortController
		constructor: (@container, @elements) ->
			@rowHeight = @elements.first().height()
			@init()
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
				onDragStart: ->
					console.log "Drag started ", @
				onDrag: ->
					console.log "Dragged ", @
				onDragEnd: ->
					console.log "Drag ended ", @

			@draggables = []
			for el in @elements
				dragOpts.trigger = $(el).find ".todo-content"
				@draggables.push Draggable.create( el, dragOpts )

			
		destroy: ->

			@draggables = null