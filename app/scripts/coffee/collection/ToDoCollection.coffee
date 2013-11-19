###

var todoModel = Parse.Object.extend('ToDo');
var todoCollectionQuery = new Parse.Query(taskModel);
taskCollectionQuery.equalTo('owner',Parse.User.current());

App.collections.ToDos = Parse.Collection.extend({
	model: todoModel,
	query: todoCollectionQuery
});

var tagModel = Parse.Object.extend('Tag');
var tagCollectionQuery = new Parse.Query(tagModel);
tagCollectionQuery.equalTo('owner',Parse.User.current());

App.collections.Tags = Parse.Collection.extend({
	model: tagModel,
	query: tagCollectionQuery
});

###

define ["model/ToDoModel"], (ToDoModel) ->
	Parse.Collection.extend
		model: ToDoModel
		initialize: ->
			@setQuery()
			@on( "destroy", (model) => @remove model )
			@on( "change:completionDate", @spawnRepeatTask )
		setQuery: ->
			@query = new Parse.Query ToDoModel
			@query.equalTo( "owner", Parse.User.current() )
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
				return _.all( tags, (tag) -> _.contains( m.get( "tags" ), tag )  )
		bumpOrder: (direction = "down", startFrom = 0, bumps = 1) ->
			if direction is "down"
				for model in swipy.todos.getActive() when model.has( "order" ) and model.get( "order" ) >= startFrom
					model.set( "order", model.get( "order" ) + bumps )
			else if direction is "up"
				for model in swipy.todos.getActive() when model.has( "order" ) and model.get( "order" ) > startFrom
					model.set( "order", model.get( "order" ) - bumps )

		spawnRepeatTask: (model, completionDate) ->
			if model.get "repeatDate" then @add model.getRepeatableDuplicate().attributes