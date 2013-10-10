define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.Model.extend
		url: "test"
		defaults: 
			snoozes:
				evening: 18
				laterTodayDelay: 3
				startOfWeek: 1 # Sunday, monday is 1
				startOfWeekend: 6 # Saturday
				weekday: { start: "Monday", morning: 9 }
				weekend: { start: "Saturday", morning: 10 }
			hasPlus: no