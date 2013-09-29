define ["underscore", "backbone", "view/scheduler/ScheduleOverlay"], (_, Backbone, ScheduleOverlayView) ->
	class ViewController
		constructor: (opts) ->
			@init()

		init: ->
			@view = new ScheduleOverlayView()
			$("body").append @view.render().el

			Backbone.on( "schedule-task", @showScheduleView, @ )
			Backbone.on( "pick-schedule-option", @pickOption, @ )
		showScheduleView: (tasks) ->
			@currentTasks = tasks
			@view.show()
		pickOption: (option) ->
			return unless @currentTasks
			console.log "Schdule ", @currentTasks, " for #{option}."
		destroy: ->
			@view.remove()
			Backbone.off( null, null, @ )
		