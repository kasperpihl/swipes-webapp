define ['backbone', 'backbone.localStorage', 'model/ToDoModel'], (Backbone, BackboneLocalStorage, ToDoModel) ->
	Backbone.Collection.extend
		model: ToDoModel
		localStorage: new Backbone.LocalStorage "SwipyTodos"
		initialize: ->
			@on 'add', (model) -> model.save()
		getActive: -> 
			now = new Date().getTime()
			@filter (m) => 
				schedule = m.getValidatedSchedule()
				if !schedule
					return false
				else 
					return schedule.getTime() < now
		getScheduled: -> 
			@where 
				schedule: null
				completionDate: null
		getCompleted: -> 
			@filter (m) => m.get("completionDate") isnt null