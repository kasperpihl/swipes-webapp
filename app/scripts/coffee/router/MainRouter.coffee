define ['backbone'], (Backbone) ->
	MainRouter = Backbone.Router.extend
		routes:
			"settings(/:id)": "settings"
			"edit/:id": "edit"
			"list/:id": "list"
			"*all": "root"
		initialize: ->
			@history = []
			@on( "route", @updateHistory )
		root: ->
			@navigate( "list/todo", { trigger: yes, replace: yes } )
		list: (id = "todo") ->
			Backbone.trigger "hide-settings"
			Backbone.trigger( "navigate/view", id )
		edit: (taskId) ->
			Backbone.trigger "hide-settings"
			Backbone.trigger( "edit/task", taskId )
		settings: (subview) ->
			Backbone.trigger "show-settings"
			if subview then Backbone.trigger( "settings/view", subview )
		updateHistory: (method, page) ->
			# We skip root, because it's just a redirect to another route.
			return false if method is "root"

			newRoute = @getRouteStr( method, page[0] )

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