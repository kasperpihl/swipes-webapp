define ["underscore", "backbone", "gsap-scroll", "gsap"], (_, Backbone) ->
	class ListSortModel
		
		constructor: (@container, @views) ->
			@rows = @getRows()
			@setBounds()
			@setRowTops()

			debouncedSetBounds = _.debounce( @setBounds, 300 )
			$(window).on( "resize scroll", => debouncedSetBounds() )
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

		setRowTops: ->
			for view in @views
				view.top = parseInt view.$el.position().top
			return @views

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
			$(window).off()
					
