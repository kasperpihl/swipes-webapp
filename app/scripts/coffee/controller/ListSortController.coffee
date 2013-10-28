define ["jquery", "model/ListSortModel", "gsap", "gsap-draggable"], ($, ListSortModel, TweenLite, Draggable) ->
	class ListSortController

		constructor: (container, views) ->
			Backbone.on( "redraw-sortable-list", @redraw, @ )
			@model = new ListSortModel( container, views )
			@listenForOrderChanges()
			@setInitialOrder()
			@createDraggables()

		setInitialOrder: ->
			@model.container.height ""
			@model.container.height( @model.container.height() )

			for view in @model.views
				view.$el.css
					position: "absolute"
					width: "100%"

				@reorderView.call( view, view.model, view.model.get( "order" ), no )
		createDraggables: ->
			if @draggables? then @killDraggables()

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

		redraw: ->
			@killDraggables()
			@model.rows = @model.getRows()
			@setInitialOrder()
			@createDraggables()

			console.log "Redraw the list"

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
		killDraggables: ->
			draggable.disable() for draggable in @draggables
			@draggables = null
			@removeInlineStyles()
		removeInlineStyles: ->
			view.$el.removeAttr "style" for view in @model.views
		destroy: ->
			@stopListenForOrderChanges()
			@killDraggables()
			Backbone.off( "redraw-sortable-list", @redraw )
			@model.destroy()
			@model = null