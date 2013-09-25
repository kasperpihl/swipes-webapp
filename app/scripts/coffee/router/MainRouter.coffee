define ['backbone'], (Backbone) ->
	MainRouter = Backbone.Router.extend
		routes:
			"": "goto"
			":term": "goto"
			"edit/:id": "edit"
		goto: (route = "todo") -> 
			Backbone.trigger( "navigate/view", route )
		edit: (taskId) ->
			Backbone.trigger( "edit/task", taskId )