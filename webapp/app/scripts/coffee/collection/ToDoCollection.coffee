define ["js/model/ToDoModel", "backbone.localStorage"], ( ToDoModel ) ->
	Backbone.Collection.extend
		model: ToDoModel
		localStorage: new Backbone.LocalStorage("ToDoCollection")
		initialize: ->
			@on( "change:deleted", (model, deleted) => if deleted then @remove model else @add model )
			@on( "change:title", (model, newTitle) => console.log "Changed title to #{newTitle}" )

			@on "reset", ->
				removeThese = []
				removeThese.push m for m in @models when m.get "deleted"
				@remove m for m in removeThese

				@invoke( "set", { rejectedByTag: no, rejectedBySearch: no } )
		updateQuery: ->

		getActive: ->
			@filter (m) -> m.getState() is "active"
		getScheduled: ->
			@filter (m) -> m.getState() is "scheduled"
		getCompleted: ->
			@filter (m) -> m.getState() is "completed"
		getActiveList: ->
			route = swipy.router.getCurrRoute()
			switch route
				when "", "list/todo", "list/scheduled", "list/completed"
					if route is "" or route is "list/todo"
						return "todo"
					else
						return route.replace( "list/", "" )
				else return "todo"
		getTasksTaggedWith: (tags, filterOnlyCurrentTasks) ->
			activeList = @getActiveList()

			switch activeList
				when "todo" then models = @getActive()
				when "scheduled" then models = @getScheduled()
				else models = @getCompleted()

			_.filter models, (m) ->
				return false unless m.has "tags"

				# If string, wrap it in an array so we can loop over it
				if typeof tags isnt "object" then tags = [tags]

				# This multi-dimensional loop returns true if
				# the model has all of the provided tags in it's tags property
				return _.all( tags, (tag) -> _.contains( m.getTagStrList(), tag )  )
		bumpOrder: (direction = "down", startFrom = 0, bumps = 1) ->
			console.log "order"
			if direction is "down"
				for model in swipy.todos.getActive() when model.has( "order" ) and model.get( "order" ) >= startFrom
					model.updateOrder (model.get( "order" ) + bumps)
			else if direction is "up"
				for model in swipy.todos.getActive() when model.has( "order" ) and model.get( "order" ) > startFrom
					model.updateOrder (model.get( "order" ) - bumps)