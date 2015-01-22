define ["underscore", "js/view/List", "js/controller/ListSortController", "js/model/TaskSortModel"], (_, ListView, ListSortController, TaskSortModel) ->
	ListView.extend
		initialize: ->
			@sorter = new TaskSortModel()
			ListView::initialize.apply( @, arguments )
		sortTasks: (tasks) ->
			return _.sortBy tasks, (model) -> model.get "order" 
		groupTasks: (tasksArr) ->
			tasksArr = @sortTasks tasksArr
			return [ { deadline: "Tasks", tasks: tasksArr } ]
		setTodoOrder: (todos) ->
			@sorter.setTodoOrder( todos, true )
		afterMovedItems: ->
			if @getTasks().length is 0
				todayOrNow = "For Today"
				swipy.analytics.sendEvent("Actions", "Cleared Tasks", todayOrNow, 0)
				swipy.analytics.sendEventToIntercom("Cleared Tasks", {"Streak": 0, "All Done for Today": todayOrNow, "Sharing Services Available": 0})
		beforeRenderList: (todos) ->
			# Make sure all todos are unselected before rendering the list
			swipy.todos.invoke( "set", "selected", no )
			@setTodoOrder todos
		afterRenderList: (todos) ->
			return unless todos.length

			# Dont init sort controller before transition in, because we need to read the height of the elements
			if @transitionDeferred? then @transitionDeferred.done =>
				if @sortController?
					@sortController.model.setViews @subviews
				else
					@sortController = new ListSortController( @$el, @subviews, => @render() )
		customCleanUp: ->
			@sortController.destroy() if @sortController?
			@sortController = null