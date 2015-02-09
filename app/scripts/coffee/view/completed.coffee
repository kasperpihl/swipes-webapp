define ["js/view/List"], (ListView) ->
	ListView.extend
		sortTasks: (tasks) ->
			result = _.sortBy tasks, (model) ->
				model.get( "completionDate" ).getTime?()

			result.reverse()
		groupTasks: (tasksArr) ->
			tasksArr = @sortTasks tasksArr
			tasksByDate = _.groupBy( tasksArr, (m) -> m.get "completionStr" )
			return ( { deadline, tasks } for deadline, tasks of tasksByDate )
		getTasks: ->
			return swipy.todos.getCompleted()