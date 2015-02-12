define ["underscore", "backbone", "gsap-scroll", "gsap"], (_, Backbone) ->
	class ListSortModel
		@HEIGHT_BREAKPOINT = 800
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

			@currRowHeight = if window.innerHeight < ListSortModel.HEIGHT_BREAKPOINT then "small" else "big"
			$(window).on "resize.sortmodel", =>
				if window.innerHeight < ListSortModel.HEIGHT_BREAKPOINT and @currRowHeight isnt "small"
					@currRowHeight = "small"
					Backbone.trigger "redraw-sortable-list"
				else if window.innerHeight >= ListSortModel.HEIGHT_BREAKPOINT and @currRowHeight isnt "big"
					@currRowHeight = "big"
					Backbone.trigger "redraw-sortable-list"

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
			newOrder = @getOrderFromPos yPos
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

		scrollWindow: (minY, maxY, y, pointerY) ->
			amount = minAmount = 20
			maxAmount = 100
			$scrollEl = $('#scrollcont')
			extraHeight = $("#main-content").position().top
			viewHeight = $scrollEl.height()
			trigger = viewHeight * 0.3

			if @oldTaskY
				delta = Math.abs @oldTaskY - y
				amount = delta
				# If user dragged thingy to the bottom/top of the screen and just want to auto-scroll fast.
				if delta < minAmount
					distToTop = pointerY - @bounds.top
					distToBottom = @bounds.bottom - y

					# scrolling up
					if distToTop < distToBottom
						if distToTop < ( trigger * 0.8 )
							amount = ( trigger - distToTop ) * 0.05
					# scrolling down
					else
						if distToBottom < ( trigger * 0.8 )
							amount = ( trigger - distToBottom ) * 0.05


				amount = Math.max( 5, Math.min( maxAmount, amount ) )
				#console.log amount
			if pointerY - trigger < @bounds.top
				newScroll = $scrollEl.scrollTop() - amount

			else if pointerY + trigger > @bounds.bottom
				newScroll = $scrollEl.scrollTop() + amount
			#console.log( "oldY: " + @oldTaskY + " new: " + y) 
			#console.log("c: " + $scrollEl.scrollTop() + " n: " + newScroll)
			TweenLite.set( $scrollEl, { scrollTo: newScroll } )
			TweenLite.set( window, { scrollTo: newScroll } )

			@oldTaskY = y
			@setBounds()
		destroy: ->
			$('#scrollcont').off(".sortmodel")
			$(window).off(".sortmodel")
			@active = no