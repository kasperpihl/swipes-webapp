define ["underscore"], (_) ->
	class TaskSortModel
		sortBySchedule: (todos) ->
			result = _.sortBy( todos, (m) -> m.get("schedule").getTime() )
			result.reverse()
			return result
			
		getEmptySpotBefore: (order, orders) ->
			if order is 0 then return undefined

			return num for num in [0..order] when not _.contains( orders, num )

			return undefined

		getEmptySpotAfter: (order, orders) ->
			order++ while _.contains(orders, order)
			return order

		findSpotForTask: (order, orders) ->
			emptySpotBefore = @getEmptySpotBefore( order, orders )
			if emptySpotBefore? then return emptySpotBefore

			return @getEmptySpotAfter( order, orders )

		swapSpots: (newSpot, oldSpot, list) ->
			oldIndex = _.indexOf( list, oldSpot )
			list.splice( oldIndex, 1, newSpot )

		subtractOnce: (list, val) ->
			# First, pick out all instances matching current order
			# then add them back minus 1
			result = _.without( list, val )
			diff = list.length - result.length - 1
			if diff > 0 then while diff--
				result.push val

			return result
		setTodoOrder: (todos) ->

			orders = _.invoke( todos, "get", "order" )
			orders = _.without( orders, undefined ) #Remove falsy values from array, like undefined.

			ordersBefore = orders
			
			withoutOrder = @sortBySchedule _.filter( todos, (m) -> not m.has "order" )


			# 1st loop – Remove any white space from orders array (Turn [3,4,5] into [0,1,2])
			for task, i in todos
				order = task.get "order"

				if not _.contains( orders, i ) 
					if withoutOrder.length 
						# First see if we can find a task without order to fit the spot
						task = withoutOrder.pop()
						task.set( "order", i )
						continue

					else
						# We couldn't, then move around items in current list
						@swapSpots( i, order, orders )
						task.set( "order", i )

			
			# 2nd loop — Reorder todos so no 2 todos have the same order and 
			# that no order is set higher than the number of todos in the list
			for task in todos
				order = task.get "order"
				
				if not order? then continue
			
				# Cap order value to number of tasks (-1 because arrays are 0-indexed)
				if order >= todos.length 
					@swapSpots( todos.length - 1, order, orders )
					order = todos.length - 1

				ordersMinusCurrent = @subtractOnce( orders, order )

				# if todos[3]?.get("title") is "fourth"
				# 	debugger

				if _.contains( ordersMinusCurrent, order )
					# Position is taken. Find a new spot and update orders array.
					spot = @findSpotForTask( order, ordersMinusCurrent )
					
					# Replace old spot with new spot
					@swapSpots( spot, order, orders )
					
					task.set( "order", spot )
				else if order is todos.length - 1
					# Order was assigned to the last spot in the list and that spot isnt taken
					task.set( "order", order )
					
				# Curr spot is available. Do nothing.
				else continue

			# 3rd loop — Assigt orders to those todos that didn't have one to begin with.
			if withoutOrder.length
				for task, i in withoutOrder
					spot = @findSpotForTask( i, orders )
					orders.push spot
					console.log "A task (#{task.get 'title'}) didn't have a spot, so we assigned it #{spot}"
					task.set( "order", spot )

			console.groupEnd()

			return todos