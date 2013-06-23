define ['backbone', 'backbone-localStorage', 'model/ToDoModel'], (Backbone, BackboneLocalStorage, ToDoModel) ->
	Backbone.Collection.extend
		model: ToDoModel
		localStorage: new Backbone.LocalStorage "SwipyTodos"
		initialize: ->
			@on 'add', (model) -> model.save()
		getActive: -> @where state: "todo"
		getScheduled: -> @where state: "scheduled"
		getCompleted: -> @where state: "completed"