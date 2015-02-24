define ["underscore", "js/model/ScheduleModel", "momentjs"], (_, ScheduleModel) ->
	class ScheduleController
		constructor: (opts) ->
			@init()
		init: ->
			@model = new ScheduleModel()

			Backbone.on( "show-scheduler", @showScheduleView, @ )
			Backbone.on( "pick-schedule-option", @pickOption, @ )
			Backbone.on( "select-date", @selectDate, @ )
		showScheduleView: (tasks) ->
			loadViewDfd = new $.Deferred()

			if not @scheduleTemplate? then require ["js/view/overlays/ScheduleOverlay"], (ScheduleOverlayView) =>
				@scheduleTemplate = ScheduleOverlayView
				loadViewDfd.resolve()
			else
				loadViewDfd.resolve()

			loadViewDfd.promise().done =>
				@view = new @scheduleTemplate( model: @model )
				$('.overlay.scheduler').remove()
				$("body").append @view.render().el
				
				@view.render()
				@view.show()
				@view.currentTasks = @currentTasks = tasks

		pickOption: (option) ->
			return unless @currentTasks
			if option is "pick a date"
				return Backbone.trigger( "select-date" )
			if typeof option is "string"
				date = @model.getDateFromScheduleOption option
			else if typeof option is "object"
				date = option.toDate()

			for task in @currentTasks
				task.scheduleTask date
			analyticsOptions =  @getAnalyticsDataFromOption( option, date )
			swipy.analytics.sendEvent( "Tasks", "Snoozed", analyticsOptions["Button Pressed"], analyticsOptions["Number of days ahead"])
			swipy.analytics.sendEventToIntercom( 'Snoozed Tasks', analyticsOptions )
			@view.currentTasks = undefined
			@view.hide()
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
		selectDate: ->
			#@view.showDatePicker()
		destroy: ->
			@view?.remove()
			Backbone.off( null, null, @ )