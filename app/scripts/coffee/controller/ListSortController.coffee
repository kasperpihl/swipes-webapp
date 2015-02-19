define ["underscore","jquery", "js/model/ListSortModel", "gsap", "gsap-draggable", "jquery-hammerjs"], (_, $, ListSortModel, TweenLite, Draggable) ->
	class ListSortController
		constructor: (container, views, @onDragCompleteCallback) ->
			@model = new ListSortModel( container, views )
			@enableTouchListners()
			_.bindAll( @, "scrolled" )
		getHammerOpts: ->
			# Options at: https://github.com/EightMedia/hammer.js/wiki/Getting-Started
			{
				drag: off
				swipe: off
				tap: off
				transform: off
				# hold_threshold: 50
				prevent_default: yes
				hold_timeout: if Modernizr.touch then 400 else 400
				domEvents:true
			}
		enableTouchListners: ->
			$( @model.container[0] ).hammer( @getHammerOpts() ).on( "press", "ol > li", @activate )
		disableTouchListeners: ->
			$( @model.container[0] ).hammer().off( "press", @activate )
		activate: (e) =>
			@disableTouchListeners()
			@model.init()
			Backbone.on( "redraw-sortable-list", @redraw, @ )
			@listenForOrderChanges()
			@setInitialOrder()
			@createDraggable @model.getViewFromId e.currentTarget.getAttribute "data-id"
			if e then @draggable.startDrag e.originalEvent.gesture.srcEvent
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
			$('#scrollcont').on('scroll.sortcontrol', @scrolled )
			@draggable = new Draggable( view.el, dragOpts )
		scrolled: ->
			@draggable?.update()
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
			view.$el.off( "click", ".todo-content", view.toggleSelected )
			view.$el.addClass "dragging"
		onDrag: (view, model) ->
			model.reorderRows( view, @y+$("#scrollcont").scrollTop() )
			#console.log @minY + "-" + @maxY + " : " + @y + " : " + @pointerY
			#model.scrollWindow( @minY, @maxY, @y, @pointerY )
		onDragEnd: (view, model, self) ->
			model.reorderRows( view, @endY )
			model.oldTaskY = null
			view.$el.removeClass( "dragging" )
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
				$('#scrollcont').off("scroll.sortcontrol")
				@draggable.disable()
				@draggable = null
				@removeInlineStyles() if removeCSS
		removeInlineStyles: ->
			view.$el.removeAttr "style" for view in @model.views
		destroy: ->
			@deactivate yes
			@disableTouchListeners()
			@model = null