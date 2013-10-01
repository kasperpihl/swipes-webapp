define ["underscore", "view/List", "controller/ListSortController"], (_, ListView, ListSortController) ->
	ListView.extend
		sortTasks: (tasks) ->
			return _.sortBy( tasks, (model) -> model.get "order" )
		
		groupTasks: (tasksArr) ->
			tasksArr = @sortTasks tasksArr
			return [ { deadline: "Tasks", tasks: tasksArr } ]

		sortBySchedule: (todos) ->
			_.sortBy( todos, (m) -> m.get("schedule").getTime() )
		
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

		setTodoOrder: (todos) ->
			orders = _.invoke( todos, "get", "order" )
			orders = _.without( orders, undefined ) #Remove falsy values from array, like undefined.
			
			withoutOrder = []

			# 1st loop — Reorder todos so no 2 todos have the same order and 
			# that no order is set higher than the number of todos in the list
			for task in todos
				order = task.get "order"
				
				if not order?
					withoutOrder.push task
					continue

				# Cap order value to number of tasks (-1 because arrays are 0-indexed)
				if order >= todos.length then order = todos.length - 1

				# First, pick out all instances matching current order
				# then add them back minus 1 replecenting current order.
				ordersMinusCurrent = _.without( orders, order )
				diff = orders.length - ordersMinusCurrent.length - 1
				if diff > 0 then while diff--
					ordersMinusCurrent.push order

				if _.contains( ordersMinusCurrent, order )
					# Position is taken. Find a new spot and update orders array.
					spot = @findSpotForTask( order, ordersMinusCurrent )
					
					# Replace old spot with new spot
					oldSpotIndex = _.indexOf( orders, order )
					orders.splice( oldSpotIndex, 1, spot )
					
					task.set( "order", spot )
				else if order is todos.length - 1
					# Order was assigned to the last spot in the list and that spot isnt taken
					# Just update the order prop and reserve the spot
					
					oldSpotIndex = _.indexOf( orders, order )
					orders.splice( oldSpotIndex, 1, spot )
					
					task.set( "order", order )
					
				# Curr spot is available. Do nothing.
				else continue

			# 2nd loop — Assigt orders to those todos that didn't have one to begin with.
			if withoutOrder.length
				withoutOrder = @sortBySchedule withoutOrder
				for task, i in withoutOrder
					spot = @findSpotForTask( i, orders )
					orders.push spot
					task.set( "order", spot )

			return todos

		beforeRenderList: (todos) ->
			@setTodoOrder todos

		afterRenderList: (todos) ->
			return unless todos.length
			
			# Alright, by now all todos have a set order. Continue on ...
			@sortController.destroy() if @sortController?

			# Dont init sort controller before transition in, because we need to read the height of the elements
			@transitionDeferred.done =>
				@disableNativeClickHandlers()
				@sortController = new ListSortController( @$el, @subviews )
		
		disableNativeClickHandlers: ->
			# SortController takes over click interaction, so disable the default behaviour
			view.$el.off( "click", ".todo-content" ) for view in @subviews
				
		customCleanUp: ->
			@sortController.destroy() if @sortController?
			@sortController = null


