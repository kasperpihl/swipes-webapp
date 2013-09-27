define ["underscore", "view/List", "controller/ListSortController", "view/list/ActionBar"], (_, ListView, ListSortController, ActionBar) ->
	ListView.extend
		sortTasks: (tasks) ->
			return _.sortBy( tasks, (model) -> model.get "order" )
		groupTasks: (tasksArr) ->
			tasksArr = @sortTasks tasksArr
			return [ { deadline: "Tasks", tasks: tasksArr } ]
		setTodoOrder: (todos) ->
			takenPositions = ( m.get "order" for m in todos when m.has "order" )
			pushOrderCount = 0

			for view, i in @subviews when !view.model.has "order"

				# If position is taken, set order to next available position
				while _.contains( takenPositions, i + pushOrderCount )
					pushOrderCount++

				view.model.set( "order", i + pushOrderCount )

			@renderList()
		afterRenderList: (todos) ->
			# If we find any todos without a defined order,
			# determine its correct order and re-render the list
			return @setTodoOrder( todos ) if _.any( todos, (m) -> not m.has "order" )
			
			# Alright, by now all todos have a set order. Continue on ...
			@sortController.destroy() if @sortController?

			# Dont init sort controller before transition in, because we need to read the height of the elements
			@transitionDeferred.done =>
				@disableNativeClickHandlers()
				@sortController = new ListSortController( @$el, @subviews )

			@actionbar = new ActionBar()
		disableNativeClickHandlers: ->
			for view in @subviews
				# Remove both (desktop) click and (mobile) touch events
				delete view.events["click .todo-content"]
				delete view.events.tap
		
				view.delegateEvents()
		customCleanUp: ->
			@sortController.destroy() if @sortController?
			@sortController = null

			for view in @subviews
				# Set events back to events hash so they'll be there for 
				# the other list types
				view.events["click .todo-content"] = "toggleSelected"
				view.events.tap = "toggleSelected"

				view.delegateEvents()


