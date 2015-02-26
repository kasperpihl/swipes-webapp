define ["js/view/List"], (ListView) ->
	ListView.extend
		getTasks: ->
			return swipy.todos.getScheduled()
		initialize: ->
			@state = "schedule"
			ListView::initialize.apply( @, arguments )