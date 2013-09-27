define ["underscore", "backbone", "view/Overlay"], (_, Backbone, Overlay) ->
	Overlay.extend
		bindEvents: ->
			@listenTo( Backbone, "schedule-task", @schedule )
		init: ->
			console.log "New Schedule Overlay created"
		schedule: (tasks) ->
			console.log "Schedule tasks: ", tasks
			@show()
		afterShow: ->
			
