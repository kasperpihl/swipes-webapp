define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.Model.extend
		url: "test"
		defaults: 
			snoozes:
				evening: 
					hour: 18
					minute: 0
				laterTodayDelay: 
					hours: 3
					minutes: 0
				weekday: 
					morning: 
						hour: 9
						minute: 0
					startDay: 
						name: "Monday"
						number: 1 # Sunday, monday is 1
				weekend: 
					morning: 
						hour: 10
						minute: 0
					startDay: 
						name: "Saturday"
						number: 6 # Saturday
			hasPlus: no