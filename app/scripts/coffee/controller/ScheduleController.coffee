define ["underscore", "backbone", "model/ScheduleModel"], (_, Backbone, ScheduleModel) ->
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

			if not @view? then require ["view/scheduler/ScheduleOverlay"], (ScheduleOverlayView) =>
				@view = new ScheduleOverlayView( model: @model )
				$("body").append @view.render().el
				loadViewDfd.resolve()
			else
				loadViewDfd.resolve()

			loadViewDfd.promise().done =>
				@view.show()
				@view.currentTasks = @currentTasks = tasks

		pickOption: (option) ->
			return unless @currentTasks
			if option is "pick a date"
				return Backbone.trigger( "select-date" )

			date = @model.getDateFromScheduleOption option

			for task in @currentTasks
				task.unset( "schedule", {silent: yes} )
				task.set { schedule: date, completionDate: null }

			@view.currentTasks = undefined
			@view.hide()
		selectDate: ->
			console.log "Select a date"
		destroy: ->
			@view?.remove()
			Backbone.off( null, null, @ )