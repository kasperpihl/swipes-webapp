define ["jquery", "gsap", "gsap-draggable"], ($, TweenLite, Draggable) ->
	class ListSortController
		
		constructor: (@container, @views) ->
			@rows = @getRows()
			@disableNativeClickHandlers()
			@setViewTops()
			@init()
		
		getRows: ->
			@rowHeight = @views[0].$el.height()
			rows = ( i * @rowHeight for view, i in @views )
			return rows

		setViewTops: ->
			for view in @views
				view.top = parseInt view.$el.position().top
			return

		disableNativeClickHandlers: ->
			for view in @views
				view.undelegateEvents()

				# Remove both (desktop) click and (mobile) touch events
				delete view.events.click
				delete view.events.tap
		
				view.delegateEvents()

		init: ->
			if @draggables? then @destroy()

			self = @
			@draggables = []
			
			for view in @views
				dragOpts = 
					type: "top"
					bounds: @container
					zIndexBoost: no
					
					# Throwing / Dragging
					edgeResistance: 0.75
					throwProps: yes
					resistance: 3000
					snap: top: (endValue) ->
						# Snap to closest row
						return Math.max( @minY, Math.min( @maxY, Math.round( endValue / self.rowHeight ) * self.rowHeight ) );

					# Handlers
					onClickParams: [view]
					onClick: @onClick
					onDragStartParams: [view, @views]
					onDragStart: @onDragStart
					onDragParams: [view, @views]
					onDrag: @onDrag
					onDragEnd: @onDragEnd

				dragOpts.trigger = view.$el.find ".todo-content"
				draggable = new Draggable( view.el, dragOpts )

				@draggables.push draggable
		
		getOrderValForView: (view) ->
			console.log "Get order value for ", view
		
		onClick: (view, allViews) =>
			@clicked = view.cid
			view.toggleSelected()
			setTimeout ( => @clicked = no ), 400

		onDragStart: (view, allViews) =>
			# Use a timer to prevent this behavior when user intent is a click, not dragging.
			setTimeout =>
					unless @clicked and @clicked is view.cid
						TweenLite.to( view.el, 0.1, { scale: 1.05, zIndex: 3, boxShadow: "0px 0px 15px 1px rgba(0,0,0,0.1)", } );
				, 100
		
		onDrag: (view, allViews) ->
			truePos = @y + view.top
			console.log "True position: #{truePos}px / y: #{@y}"
		
		onDragEnd: (view, allViews) ->
			TweenLite.to( @target, 0.25, { scale: 1, zIndex: "", boxShadow: "0 0 0 transparent", } );
		
		destroy: ->
			draggable.disable() for draggable in @draggables
			@draggables = null