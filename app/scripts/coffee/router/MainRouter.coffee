define [], () ->
	MainRouter = Backbone.Router.extend
		routes:
			"add": "add"
			"search": "search"
			"workspaces": "workspaces"
			"settings/:id": "settings"
			"settings": "settings"
			"edit/:id": "edit"
			"list/:id": "list"
			"*all": "root"
		initialize: ->
			@history = []
			@lastMainRoute = "list/todo"
			Backbone.history.on( "route", @updateHistory, @ )
			Backbone.trigger( "navigate/view", "todo" )
		root: ->
			@navigate( "list/todo", { trigger: yes, replace: yes } )
		add: ->
			Backbone.trigger( "show-add")
		search: ->
			Backbone.trigger( "show-search" )
		workspaces: ->
			Backbone.trigger( "show-workspaces" )
		list: (id = "todo") ->
			Backbone.trigger( "navigate/view", id )
			@setLastMainView()

			eventName = switch id
				when "todo" then "Today Tab"
				when "scheduled" then "Later Tab"
				when "completed" then "Done Tab"

			swipy.analytics.pushScreen eventName
		on_keypress: (e) ->
		openLastMainView: (trigger)->
			if @lastMainRoute is ""
				trigger = true
			@navigate(@lastMainRoute,trigger)
		setLastMainView: ->
			Backbone.trigger "hide-sidemenu"
			@lastMainRoute = Backbone.history.fragment
		edit: (taskId) ->

			Backbone.trigger( "edit/task", taskId )
			@setLastMainView()
			swipy.analytics.pushScreen "Edit Task"
		settings: (subview) ->
			Backbone.trigger "show-settings"
			if subview then Backbone.trigger( "settings/view", subview )
			else swipy.analytics.pushScreen "Settings menu"
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
