define ["underscore", "backbone", "gsap-scroll", "gsap"], (_, Backbone) ->
	class ListSortModel
		@HEIGHT_BREAKPOINT = 800
		constructor: (@container, @views) ->
			@rows = @getRows()
			@setBounds()

			debouncedSetBounds = _.debounce( @setBounds, 300 )
			$(window).on( "resize.sortmodel scroll.sortmodel", => debouncedSetBounds() )

			@currRowHeight = if window.innerHeight < ListSortModel.HEIGHT_BREAKPOINT then "small" else "big"
			$(window).on "resize.sortmodel", =>
				if window.innerHeight < ListSortModel.HEIGHT_BREAKPOINT and @currRowHeight isnt "small"
					@currRowHeight = "small"
					Backbone.trigger "redraw-sortable-list"
				else if window.innerHeight >= ListSortModel.HEIGHT_BREAKPOINT and @currRowHeight isnt "big"
					@currRowHeight = "big"
					Backbone.trigger "redraw-sortable-list"
		getRows: ->
			@rowHeight = @views[0].$el.height()
			rows = ( i * @rowHeight for view, i in @views )
			return rows

		setBounds: =>
			# Check if bounds is set. They won't be if element is hidden etc.
			bounds = @container[0].getClientRects()[0]? or { top: 0 }

			@bounds =
				top: Math.max( bounds.top, window.pageYOffset )
				bottom: window.innerHeight + window.pageYOffset

		getViewAtPos: (order) ->
			return view for view in @views when view.model.get( "order" ) is order

		getViewsBetween: (min, max, excludeId) ->
			views = []
			for view in @views when view.model.cid isnt excludeId
				order = view.model.get "order"
				if min <= order <= max then views.push view

			return views

		getOrderFromPos: (yPos) ->
			distances = []
			distancesWithIndex = []

			for rowTop, index in @rows
				dist = Math.abs( yPos - rowTop )
				distances.push dist
				distancesWithIndex.push { index, dist  }

			minDist = Math.min distances...

			return obj.index for obj in distancesWithIndex when obj.dist is minDist

		reorderRows: (view, yPos) ->
			newOrder = @getOrderFromPos yPos
			oldOrder = view.model.get "order"

			return if newOrder is oldOrder

			if newOrder < oldOrder
				for affectedView in @getViewsBetween( newOrder, oldOrder, view.model.cid )
					affectedView.model.set( "order", affectedView.model.get( "order" ) + 1 )

			else if newOrder > oldOrder
				for affectedView in @getViewsBetween( oldOrder, newOrder, view.model.cid )
					affectedView.model.set( "order", affectedView.model.get( "order" ) - 1 )

			# Silently set order for this view, because we don't want to trigger the handler that tweens the position for it.
			view.model.set( { order: newOrder }, { silent: yes } )

		scrollWindow: (pointerY) ->
			amount = 20

			if pointerY - 100 < @bounds.top
				newScroll = window.pageYOffset - amount

			else if pointerY + 100 > @bounds.bottom
				newScroll = window.pageYOffset + amount

			TweenLite.to( window, 0.1, { scrollTo: newScroll, ease:Linear.easeNone } )

		destroy: ->
			$(window).off(".sortmodel")

