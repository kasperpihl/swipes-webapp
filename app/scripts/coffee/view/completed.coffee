define ["view/List"], (ListView) ->
	ListView.extend
		getListItems: ->
			return swipy.todos.getCompleted()