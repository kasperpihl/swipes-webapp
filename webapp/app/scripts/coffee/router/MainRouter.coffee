define ['backbone'], (Backbone) ->
	MainRouter = Backbone.Router.extend
		routes:
			"settings/:id": "settings"
			"settings": "settings"
			"edit/:id": "edit"
			"list/:id": "list"
			"*all": "root"
		initialize: ->
			@history = []
			Backbone.history.on( "route", @updateHistory, @ )
		root: ->
			@navigate( "list/todo", { trigger: yes, replace: yes } )
		list: (id = "todo") ->
			Backbone.trigger "hide-settings"
			Backbone.trigger( "navigate/view", id )

			eventName = switch id
				when "todo" then "Tasks Tab"
				when "scheduled" then "Later Tab"
				when "completed" then "Done Tab"

			swipy.analytics.tagScreen eventName
		edit: (taskId) ->
			Backbone.trigger "hide-settings"
			Backbone.trigger( "edit/task", taskId )
		settings: (subview) ->
			Backbone.trigger "show-settings"
			if subview then Backbone.trigger( "settings/view", subview )
			else swipy.analytics.tagScreen "Settings menu"
		updateHistory: (me, page, subpage) ->
			# We skip root, because it's just a redirect to another route.
			return false if page is "" or page is "root"

			newRoute = @getRouteStr( page, subpage[0] )

			# We don't want multiple instances of the same route after
			# each other that calling router.back() would otherwise create.
			@history.push newRoute unless @getCurrRoute() is newRoute
		getRouteStr: (method, page) ->
			if page then "#{method}/#{page}" else method
		getCurrRoute: ->
			@history[ @history.length - 1 ]
		back: ->
			if @history.length > 1
				@history.pop()
				@navigate( @history[@history.length - 1], { trigger: yes, replace: yes } )
			else
				@root()
		destroy: ->
			Backbone.history.off( null, null, @ )
