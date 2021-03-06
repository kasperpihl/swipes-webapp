define ["underscore","jquery", "js/model/ListSortModel", "gsap", "gsap-draggable", "jquery-hammerjs"], (_, $, ListSortModel, TweenLite, Draggable) ->
	class ListSortController
		constructor: (container, views, @onDragCompleteCallback) ->
			@model = new ListSortModel( container, views )
			@enableTouchListners()
			Backbone.on( "drag-model", @dragModel, @)
			_.bindAll( @, "dragModel" )
		getHammerOpts: ->
			# Options at: https://github.com/EightMedia/hammer.js/wiki/Getting-Started
			{
				drag: true
				swipe: off
				tap: off
				transform: off
				# hold_threshold: 50
				prevent_default: yes
				hold_timeout: 400
				domEvents:true
			}
		dragModel: (model, e) ->
			return if @draggable?
			@activate(e, model)

		enableTouchListners: ->
			return if !@model?
			$( @model.container[0] ).hammer( @getHammerOpts() ).on( "press", "ol > li", @activate )
		disableTouchListeners: ->
			return if !@model?
			$( @model.container[0] ).hammer().off( "press", @activate )
		activate: (e, model) =>
			return if @draggable or !@model?
			@disableTouchListeners()
			@model.init()
			Backbone.on( "redraw-sortable-list", @redraw, @ )
			@listenForOrderChanges()
			@setInitialOrder()
			if model
				identifier = model.id
			else
				identifier = e.currentTarget.getAttribute "data-id"
			@createDraggable @model.getViewFromId identifier
			if e and e.originalEvent and e.originalEvent.gesture then @draggable.startDrag e.originalEvent.gesture.srcEvent else @draggable.startDrag e.originalEvent
		deactivate: (removeCSS = no) =>
			@stopListenForOrderChanges()
			@killDraggable removeCSS
			Backbone.off( "redraw-sortable-list", @redraw )
			if @model?
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
				autoScroll:1
				# Throwing / Dragging
				throwProps: yes
				edgeResistance: 0.8
				maxDuration: 0.4
				throwResistance: 3000
				snap: y: (endValue) ->
					# Snap to closest row
					result = Math.max( @minY, Math.min( @maxY, Math.round( endValue / self.model.rowHeight ) * self.model.rowHeight ) )
					return result

				# Handlers
				onDragStartParams: [view, @model.views]
				onDragStart: @onDragStart
				onDragParams: [view, @model]
				onDrag: @onDrag
				onDragEndParams: [view, @model, @]
				onDragEnd: @onDragEnd
				onThrowComplete: =>
					@onDragCompleteCallback?.call @

			dragOpts.trigger = view.$el.find ".todo-content"
			@draggable = new Draggable( view.el, dragOpts )
		redraw: ->
			@killDraggable()
			@model.rows = @model.getRows()
			@setInitialOrder()
		listenForOrderChanges: ->
			for view in @model.views
				view.model.on( "change:order", @reorderView, view )
		stopListenForOrderChanges: ->
			if @model?
				view.model.off(null, null, @) for view in @model?.views
		onDragStart: (view, allViews) =>
			view.startY = view.model.get("order") * view.$el.height()
			view.$el.off( "click", ".todo-content", view.toggleSelected )
			view.$el.addClass "dragging"
		onDrag: (view, model) ->
			yPos = parseInt(@y, 10) + parseInt(view.startY, 10)
			model.reorderRows( view, yPos )
		onDragEnd: (view, model, self) ->
			model.reorderRows( view, @endY + view.startY )
			view.startY = 0
			view.$el.removeClass( "dragging" )
			self.model.container.height ""
			setTimeout ->
					self.deactivate()
					view.$el.on( "click", ".todo-content", view.toggleSelected )
				, 500
		reorderView: (model, newOrder, animate = yes) ->
			dur = if animate then 0.3 else 0
			newY = newOrder * @$el.height()
			TweenLite.to( @$el, dur, { y: newY } )
		killDraggable: (removeCSS) ->
			if @draggable?
				@draggable.disable()
				@draggable = null
				@removeInlineStyles() if removeCSS
		removeInlineStyles: ->
			view.$el.removeAttr "style" for view in @model.views
		destroy: ->
			@deactivate yes
			Backbone.off( "drag-model", @dragModel)
			@disableTouchListeners()
			@model = null