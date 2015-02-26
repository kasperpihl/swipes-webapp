define ["underscore"], (_) ->
	Backbone.View.extend
		events:
			"click .sub-close": "handleAction"
			"click .log-out": "handleAction"
			"click .addtask.btn-icon": "handleAction"
			"click .search.btn-icon": "handleAction"
			"click .workspaces.btn-icon": "handleAction"
			"click .settings.btn-icon": "handleAction"
			"click .clickable-overlay": "handleAction"
		initialize: ->
			_.bindAll( @, "handleAction" )

		handleAction: (e) ->
			trigger = $ e.currentTarget
			if trigger.hasClass "addtask"
				swipy.router.navigate("add",true )
			else if trigger.hasClass "search"
				swipy.router.navigate("search",true )
			else if trigger.hasClass "workspaces"
				swipy.router.navigate("workspaces",true )
			else if trigger.hasClass "settings"
				swipy.router.navigate("settings",true )
			else if trigger.hasClass("clickable-overlay") or trigger.hasClass("sub-close")
				swipy.sidebar.removeSubmenu()
				swipy.router.openLastMainView(false)
			else if trigger.hasClass "log-out"
				e.preventDefault()
				if confirm "Are you sure you want to log out?"
					localStorage.clear()
					Parse.User.logOut()
					location.pathname = "/login/"
			return false
		destroy: ->
			@stopListening()