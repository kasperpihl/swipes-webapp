define ['backbone'], (Backbone) ->
	MainRouter = Backbone.Router.extend
		routes:
			"settings": "settings"
			"settings/:id": "settings"
			"edit/:id": "edit"
			":term": "goto"
			"": "goto"
		goto: (route = "todo") -> 
			Backbone.trigger "hide-settings"
			Backbone.trigger( "navigate/view", route )
		edit: (taskId) ->
			Backbone.trigger "hide-settings"
			Backbone.trigger( "edit/task", taskId )
		settings: (route) ->
			Backbone.trigger "show-settings"
			if route then Backbone.trigger( "settings/view", route )