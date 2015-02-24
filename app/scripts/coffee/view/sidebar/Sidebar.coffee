define ["underscore"], (_) ->
	Backbone.View.extend
		events:
			"click .close-sidebar": "handleAction"
			"click .log-out": "handleAction"
			"click .addtask": "handleAction"
			"click .search": "handleAction"
			"click .workspaces": "handleAction"
			"click .settings": "handleAction"
		initialize: ->
			_.bindAll( @, "handleAction" )

		handleAction: (e) ->
			trigger = $ e.currentTarget
			if trigger.hasClass "addtask"
				return Backbone.trigger("show-add")
			else if trigger.hasClass "search"
			else if trigger.hasClass "workspaces"
			else if trigger.hasClass "settings"
			else if trigger.hasClass "log-out"
				e.preventDefault()
				if confirm "Are you sure you want to log out?"
					localStorage.clear()
					Parse.User.logOut()
					location.pathname = "/login/"
		destroy: ->
			@stopListening()