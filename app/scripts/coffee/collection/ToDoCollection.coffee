define ['backbone', 'backbone.localStorage', 'model/ToDoModel'], (Backbone, BackboneLocalStorage, ToDoModel) ->
	Backbone.Collection.extend
		model: ToDoModel
		localStorage: new Backbone.LocalStorage "SwipyTodos"
		initialize: ->
			@on( "add", (model) -> model.save() )
			@on( "destroy", (model) => @remove model )
			@on( "change:completionDate", @spawnRepeatTask )
		getActive: ->
			@filter (m) => m.getState() is "active"
		getScheduled: ->
			@filter (m) => m.getState() is "scheduled"
		getCompleted: ->
			@filter (m) => m.getState() is "completed"
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
				return _.all( tags, (tag) -> _.contains( m.get( "tags" ), tag )  )
		bumpOrder: (direction = "down", startFrom = 0) ->
			if direction is "down"
				for model in swipy.todos.getActive() when model.has( "order" ) and model.get( "order" ) >= startFrom
					model.set( "order", model.get( "order" ) + 1 )
			else if direction is "up"
				for model in swipy.todos.getActive() when model.has( "order" ) and model.get( "order" ) > startFrom
					model.set( "order", model.get( "order" ) - 1 )

		spawnRepeatTask: (model, completionDate) ->
			if model.get "repeatDate" then @add model.getRepeatableDuplicate().attributes