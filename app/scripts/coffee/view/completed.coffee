define ["view/List"], (ListView) ->
	ListView.extend
		getListItems: ->
			console.log "Completed: ", swipy.todos.getCompleted()
			return swipy.todos.getCompleted()