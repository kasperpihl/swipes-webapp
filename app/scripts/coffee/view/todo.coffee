define ["view/List"], (ListView) ->
	ListView.extend
		sortTasks: (tasks) ->
			return _.sortBy tasks, (model) -> model.get("order")
		groupTasks: (tasksArr) ->
			tasksArr = @sortTasks tasksArr
			return [ { deadline: "Tasks", tasks: tasksArr } ]