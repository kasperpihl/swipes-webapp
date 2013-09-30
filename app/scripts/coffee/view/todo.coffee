define ["underscore", "view/List", "controller/ListSortController"], (_, ListView, ListSortController) ->
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

		beforeRenderList: (todos) ->
			@setTodoOrder todos

		afterRenderList: (todos) ->
			return unless todos.length
			
			# Alright, by now all todos have a set order. Continue on ...
			@sortController.destroy() if @sortController?

			# Dont init sort controller before transition in, because we need to read the height of the elements
			@transitionDeferred.done =>
				# @disableNativeClickHandlers()
				# @sortController = new ListSortController( @$el, @subviews )
		
		disableNativeClickHandlers: ->
			# SortController takes over click interaction, so disable the default behaviour
			view.$el.off( "click", ".todo-content" ) for view in @subviews
				
		customCleanUp: ->
			@sortController.destroy() if @sortController?
			@sortController = null


