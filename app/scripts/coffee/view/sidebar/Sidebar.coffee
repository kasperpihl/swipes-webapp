define ["underscore"], (_) ->
	Backbone.View.extend
		events:
			"click .sub-close": "handleAction"
			"click .log-out": "handleAction"
			"click .addtask.btn-icon": "handleAction"
			"click .search.btn-icon": "handleAction"
			"click .workspaces.btn-icon": "handleAction"
			"click .settings.btn-icon": "handleAction"
		initialize: ->
			_.bindAll( @, "handleAction" )

		handleAction: (e) ->
			trigger = $ e.currentTarget
			if trigger.hasClass "addtask"
				swipy.sidebar.loadAdd()
			else if trigger.hasClass "search"
				swipy.sidebar.loadSearchFilter()
			else if trigger.hasClass "workspaces"
				swipy.sidebar.loadTagFilter()
			else if trigger.hasClass "settings"
				swipy.sidebar.loadSettings()
			else if trigger.hasClass "sub-close"
				swipy.sidebar.removeSubmenu()
			else if trigger.hasClass "log-out"
				e.preventDefault()
				if confirm "Are you sure you want to log out?"
					localStorage.clear()
					Parse.User.logOut()
					location.pathname = "/login/"
			return false
		destroy: ->
			@stopListening()