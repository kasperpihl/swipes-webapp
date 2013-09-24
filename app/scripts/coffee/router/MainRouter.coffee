define ['backbone'], (Backbone) ->
	MainRouter = Backbone.Router.extend
		routes:
			":term": "goto"
			"edit/:id": "edit"
			"": "goto"
		goto: (route = "todo") -> 
			Backbone.trigger( "navigate/view", route )
		edit: (taskId) ->
			Backbone.trigger( "edit/task", taskId )

	return MainRouter