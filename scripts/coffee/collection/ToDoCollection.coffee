define ['backbone', 'backbone-localStorage', 'model/ToDoModel'], (Backbone, BackboneLocalStorage, ToDoModel) ->
	Backbone.Collection.extend
		model: ToDoModel
		localStorage: new Backbone.LocalStorage "SwipyTodos"
		getActive: -> @where status: "todo"
		getScheduled: -> @where status: "scheduled"
		getArchived: -> @where status: "archived"