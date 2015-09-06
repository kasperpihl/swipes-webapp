define ["underscore", "js/model/extra/ScheduleModel", "js/view/modal/ScheduleModal", "momentjs"], (_, ScheduleModel, ScheduleModal) ->
	class ScheduleController
		constructor: (opts) ->
			@init()
		init: ->
			@model = new ScheduleModel()

			Backbone.on( "show-scheduler", @showScheduleView, @ )
			_.bindAll( @ , "scheduleModalCallback" )
		showScheduleView: (taskCards, e) ->
			@view?.remove()
			@model.updateData()
			@view = new ScheduleModal( model: @model )
			@view.render()
			@view.presentModal({left: e.clientX+30, top:e.clientY+30, centerY: true, centerX: true}, @scheduleModalCallback)

			@currentCards = taskCards
			@currentTasks = _.pluck( taskCards, "model" )

		scheduleModalCallback: (option) ->
			return unless @currentTasks
			return if !option
			if typeof option is "string"
				date = @model.getDateFromScheduleOption option
			else if typeof option is "object"
				date = option.toDate()
			deferredArr = []
			console.log option
			for taskCard in @currentCards
				deferredArr.push taskCard.animateWithClass("fadeOutLeft")
			$.when( deferredArr... ).then => 
				_.invoke(@currentTasks, "scheduleTask", date)
			analyticsOptions =  @getAnalyticsDataFromOption( option, date )
			swipy.analytics.sendEventToIntercom( 'Snoozed Tasks', analyticsOptions )

		getAnalyticsDataFromOption: (option, date) ->
			if typeof option is "object"
				option = "Calendar"
			else
				option = switch option
					when "later today" then "Later Today"
					when "this evening" then "This Evening"
					when "tomorrow" then "Tomorrow"
					when "day after tomorrow" then "In 2 Days"
					when "this weekend" then "This Weekend"
					when "next week" then "Next Week"
					else "Unspecified"

			return {
				"Button Pressed": option
				"Number of Tasks": @currentTasks.length
				"Number of days ahead": @getDayDiff date
				"Used Time Picker": "No"
			}
		getDayDiff: (date) ->
			# For unspecified
			if not date then return ""

			# Convert to Moment so we can do queries
			diff = moment( date ).diff( new moment(), "days" )

			if diff < 7
				return diff
			else if diff < 15
				return "7-14"
			else if diff < 29
				return "15-28"
			else if diff < 43
				return "29-42"
			else if diff < 57
				return "43-56"
			else
				return "56+"

			return diff
		destroy: ->
			@view?.remove()
			Backbone.off( null, null, @ )