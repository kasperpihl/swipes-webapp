define ["view/List"], (ListView) ->
	ListView.extend
		sortTasks: (tasks) ->
			return _.sortBy tasks, (model) -> model.get("order")