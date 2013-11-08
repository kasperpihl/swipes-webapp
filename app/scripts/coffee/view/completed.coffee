define ["view/List"], (ListView) ->
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
		markTaskAsTodo: (tasks) ->
			for task in tasks
				view = @getViewForModel task

				# Wrap in do, so reference to model isn't changed next time the loop iterates
				if view? then do ->
					m = task
					view.swipeLeft("todo").then =>
						m.set
							completionDate: null
							schedule: m.getDefaultSchedule()