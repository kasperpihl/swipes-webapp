define ["jquery", "model/ListSortModel", "gsap", "gsap-draggable", "hammerjs"], ($, ListSortModel, TweenLite, Draggable) ->
	class ListSortController
		constructor: (container, views, @onDragCompleteCallback) ->
			@model = new ListSortModel( container, views )
			@enableTouchListners()
		enableTouchListners: ->
			@model.container.hammer().on( "hold", "ol li", @activate )
		disableTouchListeners: ->
			@model.container.hammer().off( "hold", @activate )
		activate: (e) =>
			@disableTouchListeners()
			@model.init()
			Backbone.on( "redraw-sortable-list", @redraw, @ )
			@listenForOrderChanges()
			@setInitialOrder()
			@createDraggable @model.getViewFromId e.currentTarget.getAttribute "data-id"
			if e then @draggable.startDrag e.gesture.srcEvent
		deactivate: (removeCSS = no) =>
			@stopListenForOrderChanges()
			@killDraggable removeCSS
			Backbone.off( "redraw-sortable-list", @redraw )
			@model.destroy()
			@enableTouchListners()
		setInitialOrder: ->
			@model.container.height ""
			@model.container.height( @model.container.height() )

			for view in @model.views
				view.$el.css { position: "absolute", width: "100%" }
				@reorderView.call( view, view.model, view.model.get( "order" ), no )
		createDraggable: (view) ->
			if @draggable? then @killDraggable()

			self = @

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
				onDragStartParams: [view, @model.views]
				onDragStart: @onDragStart
				onDragParams: [view, @model]
				onDrag: @onDrag
				onDragEndParams: [view, @model]
				onDragEnd: @onDragEnd
				onThrowComplete: =>
					@deactivate()
					@onDragCompleteCallback?.call @

			dragOpts.trigger = view.$el.find ".todo-content"
			@draggable = new Draggable( view.el, dragOpts )
		redraw: ->
			@killDraggables()
			@model.rows = @model.getRows()
			@setInitialOrder()
			@createDraggables()
		listenForOrderChanges: ->
			for view in @model.views
				view.model.on( "change:order", @reorderView, view )
		stopListenForOrderChanges: ->
			if @model?
				view.model.off(null, null, @) for view in @model?.views
		onDragStart: (view, allViews) =>
			view.$el.addClass "selected"
		onDrag: (view, model) ->
			model.reorderRows( view, @y )
			model.scrollWindow( @pointerY )
		onDragEnd: (view, model) ->
			model.reorderRows( view, @endY )
			view.$el.removeClass( "selected" ) unless view.model.get "selected"
		reorderView: (model, newOrder, animate = yes) ->
			dur = if animate then 0.3 else 0
			TweenLite.to( @el, dur, { top: newOrder * @$el.height() } )
		killDraggable: (removeCSS) ->
			if @draggable?
				@draggable.disable()
				@draggable = null
				@removeInlineStyles() if removeCSS
		removeInlineStyles: ->
			view.$el.removeAttr "style" for view in @model.views
		destroy: ->
			@deactivate yes
			@disableTouchListeners()
			@model = null