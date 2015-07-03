define [], () ->
	MainRouter = Backbone.Router.extend
		routes:
			"add": "add"
			"settings/:id": "settings"
			"settings": "settings"
			"edit/:id": "edit"
			"edit/:id/:action": "edit"
			"tasks/:id": "tasks"
			"project/:id": "project"
			"member/:id": "member"
			"list/:id/:action": "tasks"
			"work": "work"
			"*all": "root"
		initialize: ->
			@history = []
			@lastMainRoute = "now"
			Backbone.history.on( "route", @updateHistory, @ )
		root: ->
			@navigate( "tasks/now", { trigger: yes, replace: yes } )
		add: ->
			Backbone.trigger( "show-add")	
		search: ->
			Backbone.trigger( "show-search" )
		workspaces: ->
			Backbone.trigger( "show-workspaces" )
		work: ->
			Backbone.trigger( "work-mode" )

		tasks: (id = "now", action ) ->
			options = { id: id }
			if action
				options["action"] = action
			Backbone.trigger( "open/viewcontroller", "tasks", options )
			@setLastMainView()
			eventName = switch id
				when "now" then "Now Tab"
				when "later" then "Later Tab"
				when "done" then "Done Tab"

			swipy.analytics.pushScreen eventName
		project: ( id ) ->
			options = { id: id }
			Backbone.trigger( "open/viewcontroller", "project", options )
		member: ( id ) ->
			options = { id: id }
			Backbone.trigger( "open/viewcontroller", "member", options )
		openLastMainView: (trigger)->
			if @lastMainRoute is ""
				trigger = true
			@navigate(@lastMainRoute,trigger)
		setLastMainView: ->
			Backbone.trigger "hide-sidemenu"
			@lastMainRoute = Backbone.history.fragment
		edit: (taskId, action) ->

			Backbone.trigger( "edit/task", taskId )
			@setLastMainView()
			swipy.analytics.pushScreen "Edit Task"
		settings: (subview) ->
			Backbone.trigger "show-settings"
			if subview then Backbone.trigger( "settings/view", subview )
			else swipy.analytics.pushScreen "Settings menu"
		updateHistory: (me, page, subpage) ->
			if @history.length is 0 and page isnt "edit" and page isnt "list"
				Backbone.trigger( "open/viewcontroller", "tasks", {id:"now", onlyInstantiate: true} )
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
