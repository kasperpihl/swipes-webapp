define ['backbone', 'backbone.localStorage', 'model/ToDoModel'], (Backbone, BackboneLocalStorage, ToDoModel) ->
	Backbone.Collection.extend
		model: ToDoModel
		localStorage: new Backbone.LocalStorage "SwipyTodos"
		initialize: ->
			@on( "add", (model) -> model.save() )
			@on( "destroy", (model) => @remove model )
		getActive: -> 
			now = new Date().getTime()
			@filter (m) => 
				schedule = m.getValidatedSchedule()
				
				if not schedule or m.get "completionDate"
					return false
				else
					return schedule.getTime() <= now
		getScheduled: -> 
			now = new Date().getTime()
			
			@filter (m) =>
				return false if m.get "completionDate"

				schedule = m.getValidatedSchedule()
				return true if schedule is null # Means 'unspecified'
				return schedule.getTime() > now
		getCompleted: -> 
			@filter (m) =>
				m.get("completionDate")?