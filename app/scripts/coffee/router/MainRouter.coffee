define ['backbone'], (Backbone) ->
	MainRouter = Backbone.Router.extend
		routes:
			"": "goto"
			":term": "goto"
			"edit/:id": "edit"
			"settings": "settings"
			"settings/:id": "settings"
		goto: (route = "todo") -> 
			Backbone.trigger "hide-settings"
			Backbone.trigger( "navigate/view", route )
		edit: (taskId) ->
			Backbone.trigger "hide-settings"
			Backbone.trigger( "edit/task", taskId )
		settings: (route) ->
			Backbone.trigger "show-settings"
			Backbone.trigger( "settings/view", route )