define ["underscore", "gsap-scroll", "gsap"], (_) ->
	class ListSortModel
		constructor: (@container, views) ->
			@active = no
			@setViews views
		setViews: (views) ->
			@views = views
			if @active
				@rows = @getRows()
				@setBounds()
		init: ->
			@rows = @getRows()
			@setBounds()
			_.bindAll( @, "scrolled")
			@debouncedSetBounds = _.debounce( @setBounds, 300 )
			$('#scrollcont').on('scroll.sortmodel', @scrolled )
			$(window).on( "resize.sortmodel", => debouncedSetBounds() )
			@active = yes
		scrolled: (e) ->
			@debouncedSetBounds()
		getRows: ->
			@rowHeight = @views[0].$el.height()
			rows = ( i * @rowHeight for view, i in @views )
			return rows

		setBounds: =>
			# Check if bounds is set. They won't be if element is hidden etc.
			bounds = @container[0].getClientRects()[0]? or { top: 0 }

			@bounds =
				top: $('#scrollcont').scrollTop()
				bottom: $('#scrollcont').height() + $('#scrollcont').scrollTop()

		getViewAtPos: (order) ->
			console.log @views
			return view for view in @views when view.model.get( "order" ) is order

		getViewFromId: (id) ->
			for view in @views when view.el.getAttribute( "data-id" ) is id
				return view

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
			newOrder = @getViewAtPos(@getOrderFromPos(yPos)).model.get("order")
			console.log newOrder
			oldOrder = view.model.get "order"
			return if newOrder is oldOrder

			if newOrder < oldOrder
				for affectedView in @getViewsBetween( newOrder, oldOrder, view.model.cid )
					affectedView.model.updateOrder (affectedView.model.get( "order" ) + 1)

			else if newOrder > oldOrder
				for affectedView in @getViewsBetween( oldOrder, newOrder, view.model.cid )
					affectedView.model.updateOrder (affectedView.model.get( "order" ) - 1 )

			# Silently set order for this view, because we don't want to trigger the handler that tweens the position for it.
			view.model.updateOrder newOrder, { silent: true } 

		destroy: ->
			$('#scrollcont').off(".sortmodel")
			$(window).off(".sortmodel")
			@active = no