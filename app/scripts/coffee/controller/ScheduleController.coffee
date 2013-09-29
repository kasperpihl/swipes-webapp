define ["underscore", "backbone", "view/scheduler/ScheduleOverlay", "model/DateConverter"], (_, Backbone, ScheduleOverlayView, DateConverter) ->
	class ViewController
		constructor: (opts) ->
			@init()

		init: ->
			@view = new ScheduleOverlayView()
			@dateConverter = new DateConverter()
			$("body").append @view.render().el

			Backbone.on( "schedule-task", @showScheduleView, @ )
			Backbone.on( "pick-schedule-option", @pickOption, @ )
		showScheduleView: (tasks) ->
			@currentTasks = tasks
			@view.show()
		pickOption: (option) ->
			return unless @currentTasks
			date = @dateConverter.getDateFromScheduleOption option
			
			for task in @currentTasks
				task.unset( "schedule", {silent: yes} )
				task.set( "schedule", date )
			
			@view.hide()
		destroy: ->
			@view.remove()
			Backbone.off( null, null, @ )
		