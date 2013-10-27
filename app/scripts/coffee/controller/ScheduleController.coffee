define ["underscore", "backbone", "view/scheduler/ScheduleOverlay", "model/ScheduleModel"], (_, Backbone, ScheduleOverlayView, ScheduleModel) ->
	class ScheduleController
		constructor: (opts) ->
			@init()

		init: ->
			@model = new ScheduleModel()
			@view = new ScheduleOverlayView( model: @model )
			$("body").append @view.render().el

			Backbone.on( "show-scheduler", @showScheduleView, @ )
			Backbone.on( "pick-schedule-option", @pickOption, @ )
			Backbone.on( "select-date", @selectDate, @ )
		showScheduleView: (tasks) ->
			@view.currentTasks = @currentTasks = tasks
			@view.show()
		pickOption: (option) ->
			return unless @currentTasks
			if option is "pick a date"
				return Backbone.trigger( "select-date" )

			if typeof option is "string"
				date = @model.getDateFromScheduleOption option
			else if typeof option is "object"
				date = option.toDate()

			for task in @currentTasks
				task.unset( "schedule", {silent: yes} )
				task.set { schedule: date, completionDate: null }

			@view.currentTasks = undefined
			@view.hide()
		selectDate: ->
			@view.showDatePicker()
		destroy: ->
			@view.remove()
			Backbone.off( null, null, @ )