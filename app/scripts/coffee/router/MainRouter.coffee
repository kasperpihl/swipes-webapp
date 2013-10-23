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
			@navigate( "list/todo", { trigger: yes, replaceState: no } )
		list: (id) ->
			# console.log "Go to list #{id}"
			Backbone.trigger "hide-settings"
			Backbone.trigger( "navigate/view", id )
		edit: (taskId) ->
			console.log "Edit task #{taskId}"
			Backbone.trigger "hide-settings"
			Backbone.trigger( "edit/task", taskId )
		settings: (subview) ->
			console.log "Going to settings"
			Backbone.trigger "show-settings"
			if subview then Backbone.trigger( "settings/view", subview )
		updateHistory: (method, page) ->
			unless method is "root" then @history.push @getRouteStr( method, page[0] )
		getRouteStr: (method, page) ->
			if page then "#{method}/#{page}" else method
		back: ->
			if @history.length > 0
				window.history.back()

			else
				# If we don't have any history, go to the root
				# Use replaceState if available so the navigation doesn't create an extra history entry
				this.navigate( 'list/todo', {trigger:true, replace:true} )


