define ['backbone'], (Backbone) ->
	MainRouter = Backbone.Router.extend
		routes:
			"": "goto"
			":term": "goto"
			"edit/:id": "edit"
		initialize: ->
			console.log "Something is wrong in the state of Denmark..."
		goto: (route = "todo") -> 
			Backbone.trigger( "navigate/view", route )
		edit: (taskId) ->
			Backbone.trigger( "edit/task", taskId )