define ["view/List"], (ListView) ->
	ListView.extend
		sortTasks: (tasks) ->
			return _.sortBy( tasks, (model) -> model.get( "schedule" ).getTime() ).reverse()
		groupTasks: (tasksArr) ->
			tasksArr = @sortTasks tasksArr
			tasksByDate = _.groupBy( tasksArr, (m) -> m.get "completionStr" )
			return ( { deadline, tasks } for deadline, tasks of tasksByDate )
		getListItems: ->
			return swipy.todos.getCompleted()