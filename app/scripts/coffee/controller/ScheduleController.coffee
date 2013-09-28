define ["underscore", "backbone", "view/scheduler/ScheduleOverlay"], (_, Backbone, ScheduleOverlayView) ->
	class ViewController
		constructor: (opts) ->
			@init()

		init: ->
			@view = new ScheduleOverlayView()
			$("body").append @view.render().el

			Backbone.on( "schedule-task", @scheduleTasks, @ )

		scheduleTasks: (tasks) ->
			console.log "Schedule tasks: ", tasks
			@view.show()

		destroy: ->
			@view.remove()
			Backbone.off( null, null, @ )
		