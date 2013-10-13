define ['backbone', 'backbone.localStorage', 'model/ToDoModel'], (Backbone, BackboneLocalStorage, ToDoModel) ->
	Backbone.Collection.extend
		model: ToDoModel
		localStorage: new Backbone.LocalStorage "SwipyTodos"
		initialize: ->
			@on( "add", (model) -> model.save() )
			@on( "destroy", (model) => @remove model )
		getActive: -> 
			@filter (m) => m.getState() is "active"
		getScheduled: -> 
			@filter (m) => m.getState() is "scheduled"
		getCompleted: -> 
			@filter (m) => m.getState() is "completed"
		bumpOrder: (direction = "down", startFrom = 0) ->
			if direction is "down"
				for model in swipy.todos.getActive() when model.has( "order" ) and model.get( "order" ) >= startFrom
					model.set( "order", model.get( "order" ) + 1 )
			else if direction is "up"
				for model in swipy.todos.getActive() when model.has( "order" ) and model.get( "order" ) > startFrom
					model.set( "order", model.get( "order" ) - 1 )