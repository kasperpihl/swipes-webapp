define ["jquery", "model/ListSortModel", "gsap", "gsap-draggable"], ($, ListSortModel, TweenLite, Draggable) ->
	class ListSortController
		
		constructor: (container, views) ->
			@model = new ListSortModel( container, views )
			@listenForOrderChanges()
			@setInitialOrder()
			@init()

		setInitialOrder: ->
			@model.container.height( @model.container.height() )
			for view in @model.views
				view.$el.css
					position: "absolute"
					width: "100%"
				
				@reorderView.call( view, view.model, view.model.get( "order" ), no )

		init: ->
			if @draggables? then @destroy()

			self = @
			@draggables = []
			
			for view in @model.views
				dragOpts = 
					type: "top"
					bounds: @model.container
					
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
			view.model.off(null, null, @) for view in @model.views
				
		onClick: (view, allViews) =>
			@clicked = view.cid
			view.toggleSelected()
			setTimeout ( => @clicked = no ), 400

		onDragStart: (view, allViews) =>
			# Use a timer to prevent this behavior when user intent is a click, not dragging.
			setTimeout =>
					unless @clicked and @clicked is view.cid
						view.$el.addClass "selected"
				, 100

		onDrag: (view, model) ->
			model.reorderRows( view, @y )
			# if Modernizr.touch then model.scrollWindow( @pointerY )
			model.scrollWindow( @pointerY )
		onDragEnd: (view, model) ->
			model.reorderRows( view, @endY )
			view.$el.removeClass( "selected" ) unless view.model.get "selected"

		reorderView: (model, newOrder, animate = yes) ->
			dur = if animate then 0.3 else 0
			TweenLite.to( @el, dur, { top: newOrder * @$el.height() } )
		
		destroy: ->
			@stopListenForOrderChanges()
			draggable.disable() for draggable in @draggables
			@draggables = null
			@model.destroy()
			@model = null