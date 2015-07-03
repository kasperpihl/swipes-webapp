define ["underscore"], (_) ->
	Backbone.View.extend
		events:
			"click .sub-back": "handleAction"
			"click .log-out": "handleAction"
			"click .addtask.btn-icon": "handleAction"
			"click .search.btn-icon": "handleAction"
			"click .workspaces.btn-icon": "handleAction"
			"click .settings.btn-icon": "handleAction"
			"click .clickable-overlay": "handleAction"
			"click .swipes-logo": "handleAction"
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
			else if trigger.hasClass("clickable-overlay") or trigger.hasClass( "sub-back" )
				swipy.sidebar.popView(trigger.hasClass("clickable-overlay"))
			else if trigger.hasClass("swipes-logo")
				swipy.router.navigate("tasks/now", true)
			return false
		destroy: ->
			@stopListening()