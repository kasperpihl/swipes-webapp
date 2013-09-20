define ["jquery", "model/ListSortModel", "gsap", "gsap-draggable"], ($, ListSortModel, TweenLite, Draggable) ->
	class ListSortController
		
		constructor: (container, views) ->
			@model = new ListSortModel( container, views )
			@disableNativeClickHandlers()
			@listenForOrderChanges()
			@setInitialOrder()
			@init()

		disableNativeClickHandlers: ->
			for view in @model.views
				view.undelegateEvents()

				# Remove both (desktop) click and (mobile) touch events
				delete view.events.click
				delete view.events.tap
		
				view.delegateEvents()

		setInitialOrder: ->
			@model.container.height( @model.container.height() )
			for view in @model.views
				view.$el.css
					position: "absolute"
					width: "100%"
				
				@reorderView.call( view, view.model, view.model.get "order" )

		init: ->
			if @draggables? then @destroy()

			self = @
			@draggables = []
			
			for view in @model.views
				dragOpts = 
					type: "top"
					bounds: @model.container
					zIndexBoost: no
					
					# Throwing / Dragging
					edgeResistance: 0.75
					throwProps: yes
					resistance: 3000
					snap: top: (endValue) ->
						# Snap to closest row
						return Math.max( @minY, Math.min( @maxY, Math.round( endValue / self.model.rowHeight ) * self.model.rowHeight ) );

					# Handlers
					onClickParams: [view]
					onClick: @onClick
					onDragStartParams: [view, @model.views]
					onDragStart: @onDragStart
					onDragParams: [view, @model]
					onDrag: @onDrag
					onDragEndParams: [view, @model]
					onDragEnd: @onDragEnd

				dragOpts.trigger = view.$el.find ".todo-content"
				draggable = new Draggable( view.el, dragOpts )

				@draggables.push draggable

		listenForOrderChanges: ->
			for view in @model.views
				view.model.on( "change:order", @reorderView, view )

		stopListenForOrderChanges: ->
			view.model.off() for view in @model.views
				
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
		
		onDrag: (view, model) ->
			# Limit this function call to once every 250ms or something
			model.reorderRows( view, @y )
		
		onDragEnd: (view, model) ->
			model.reorderRows( view, @endY )
			TweenLite.to( @target, 0.25, { scale: 1, zIndex: "", boxShadow: "0 0 0 transparent", } );

		reorderView: (model, newOrder) ->
			TweenLite.to( @el, 0.3, { top: newOrder * @$el.height() } )
		
		destroy: ->
			@stopListenForOrderChanges()
			draggable.disable() for draggable in @draggables
			@draggables = null
			@model.destroy()
			@model = null