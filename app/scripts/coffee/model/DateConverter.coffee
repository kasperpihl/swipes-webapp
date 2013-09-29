define ["underscore"], (_) ->
	class DateConverter
		constructor: ->
			console.log "Date Converter created"
		getDateFromScheduleOption: (option) ->
			return new Date()