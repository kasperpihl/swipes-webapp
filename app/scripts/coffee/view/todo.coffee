define ["underscore", "view/List", "controller/ListSortController", "model/TaskSortModel"], (_, ListView, ListSortController, TaskSortModel) ->
	ListView.extend
		initialize: ->
			@sorter = new TaskSortModel()
			ListView::initialize.apply( @, arguments )
		sortTasks: (tasks) ->
			return _.sortBy( tasks, (model) -> model.get "order" )

		groupTasks: (tasksArr) ->
			tasksArr = @sortTasks tasksArr
			return [ { deadline: "Tasks", tasks: tasksArr } ]

		setTodoOrder: (todos) ->
			@sorter.setTodoOrder todos

		beforeRenderList: (todos) ->
			@setTodoOrder todos

		afterRenderList: (todos) ->
			return unless todos.length

			# Alright, by now all todos have a set order. Continue on ...
			@sortController.destroy() if @sortController?

			# Dont init sort controller before transition in, because we need to read the height of the elements
			if @transitionDeferred? then @transitionDeferred.done =>
				@disableNativeClickHandlers()
				@sortController = new ListSortController( @$el, @subviews )

		disableNativeClickHandlers: ->
			# SortController takes over click interaction, so disable the default behaviour
			view.$el.off( "click", ".todo-content" ) for view in @subviews

		customCleanUp: ->
			console.log "Cleaning up view"
			@sortController.destroy() if @sortController?
			@sortController = null


