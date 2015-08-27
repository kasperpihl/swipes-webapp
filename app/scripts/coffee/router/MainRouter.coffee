define [], () ->
	MainRouter = Backbone.Router.extend
		routes:
			"add": "add"
			"settings/:id": "settings"
			"settings": "settings"
			"edit/:id": "edit"
			"edit/:id/:action": "edit"
			"tasks/:id": "tasks"
			"task/:id": "task"
			"channel/:id": "channel"
			"channel/:id/:action/:actionId": "channel"
			"im/:id": "im"
			"im/:id/:action/:actionId": "im"
			"group/:id": "group"
			"group/:id/:action/:actionId": "group"
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
		task: (id) ->
			task = swipy.collections.todos.get(id)
			if task
				pathStart = "tasks/now"
				channelId = task.get("projectLocalId")
				channel = swipy.slackCollections.channels.get(channelId)
				if channel
					if channel.get("is_channel")
						pathStart = "channel/" + channel.get("name")
					if channel.get("is_group")
						pathStart = "group/" + channel.get("name")
					if channel.get("is_im")
						user = swipy.slackCollections.users.get(channel.get("user"))
						pathStart = "im/" + user.get("name")
				
				fullPath = pathStart + "/task/" + task.id
				console.log "compare", @getCurrRoute(), @lastMainRoute, pathStart
				if @getCurrRoute()?.startsWith(pathStart)
					console.log "current path"
					Backbone.trigger("edit/task", task)
					@navigate( fullPath, {trigger: no })
				else
					@navigate( fullPath, {trigger: yes})
			else
				@root()

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
		channel: ( id, action, actionId ) ->
			options = { id: id, action: action, actionId: actionId }
			Backbone.trigger( "open/viewcontroller", "channel", options )
		im: ( id, action, actionId ) ->
			options = { id: id, action: action, actionId: actionId }
			Backbone.trigger( "open/viewcontroller", "im", options )
		group: (id, action, actionId) ->
			options = { id: id, action: action, actionId: actionId }
			Backbone.trigger( "open/viewcontroller", "group", options )
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
			if @history.length is 0 and page isnt "edit" and page isnt "tasks" and page isnt "channel" and page isnt "im"
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
