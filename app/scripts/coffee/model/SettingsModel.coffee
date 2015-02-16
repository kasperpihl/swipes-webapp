define ["underscore"], (_) ->
	Backbone.Model.extend
		className: "Settings"
		defaults:
			SettingLaterToday:
				3 * 3600
			SettingEveningStartTime:
				19 * 3600
			SettingWeekStartTime:
				9 * 3600
			SettingWeekStart:
				1
			SettingWeekendStartTime:
				10 * 3600
			SettingWeekendStart:
				2
			SettingAddToBottom:
				false
			SettingFilter:
				""
			snoozes:
				weekday:
					startDay:
						name: "Monday"
						number: 1 # Sunday, monday is 1
				weekend:
					startDay:
						name: "Saturday"
						number: 6 # Saturday
			hasPlus: no