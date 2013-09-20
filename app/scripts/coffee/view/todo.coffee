###

	# Libraries
	1. https://github.com/farhadi/html5sortable/blob/master/jquery.sortable.js
	2. GreenSock Draggable (Fucking lækkert!) - http://greensock.com/draggable/

	# Kasper
	1. https://github.com/kasperpihl/swipes-ios/blob/master/Swipes/Classes/Models/CustomClasses/KPToDo.m#L184
	2. https://github.com/kasperpihl/swipes-ios/blob/master/Swipes/Classes/Handlers/ItemHandler.m#L71


###

define ["underscore", "view/List", "controller/ListSortController"], (_, ListView, ListSortController) ->
	ListView.extend
		sortTasks: (tasks) ->
			return _.sortBy tasks, (model) -> model.get("order")
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

			@sortController = new ListSortController( @$el, @subviews )
