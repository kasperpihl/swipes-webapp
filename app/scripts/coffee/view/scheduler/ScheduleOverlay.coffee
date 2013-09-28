define ["underscore", "backbone", "view/Overlay", "text!templates/schedule-overlay.html"], (_, Backbone, Overlay, ScheduleOverlayTmpl) ->
	Overlay.extend
		className: 'overlay scheduler'
		bindEvents: ->
			
		init: ->
			console.log "New Schedule Overlay created"
		setTemplate: ->
			@template = _.template ScheduleOverlayTmpl
		afterShow: ->
			console.log "Schedule overlay shown"
			
