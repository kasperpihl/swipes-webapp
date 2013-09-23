define ['view/List'], (ListView) ->
	ListView.extend
		getTasks: ->
			return swipy.todos.getScheduled()