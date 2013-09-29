define ["underscore", "momentjs"], (_, Moment) ->
	class ScheduleModel
		constructor: (@settings, @now) ->
			if not @now? then @now = moment()
			
			@validateSettings()
			@data = @getData()
		validateSettings: ->

		getData: ->
			return [
				{ id: "later today", title: @getDynamicTime( "Later Today" ), disabled: no }
				{ id: "this evening", title: @getDynamicTime( "This Evening" ), disabled: no }
				{ id: "tomorrow", title: @getDynamicTime( "Tomorrow" ), disabled: no }
				{ id: "day after tomorrow", title: @getDynamicTime( "Day After Tomorrow" ), disabled: no }
				{ id: "this weekend", title: @getDynamicTime( "This Weekend" ), disabled: no }
				{ id: "next week", title: @getDynamicTime( "Next Week" ), disabled: no }
				{ id: "unspecified", title: @getDynamicTime( "Unspecified" ), disabled: no }
				{ id: "at location", title: @getDynamicTime( "At Location" ), disabled: yes }
				{ id: "pick a date", title: @getDynamicTime( "Pick A Date" ), disabled: no }
			]

		getDateFromScheduleOption: (option) ->
			return new Date()

		getDynamicTime: (time) ->
			switch time
				when "This Evening"
					# Check settings for 'this evening' setting, but for now just use 18:00
					return if @now.hour() >= 18 then "Tomorrow Evening" else "This Evening"
				when "Day After Tomorrow"
					dayAfterTomorrow = moment @now
					dayAfterTomorrow.day ( dayAfterTomorrow.day() + 2 )

					return dayAfterTomorrow.format "dddd"
				else 
					return time

		toJSON: ->
			return { options: @data }
