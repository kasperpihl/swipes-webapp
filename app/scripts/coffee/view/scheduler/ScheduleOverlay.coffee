define ["underscore", "backbone", "view/Overlay", "text!templates/schedule-overlay.html"], (_, Backbone, Overlay, ScheduleOverlayTmpl) ->
	Overlay.extend
		className: 'overlay scheduler'
		events: 
			"click .grid > a": "selectOption"
		bindEvents: ->
			
		init: ->
			console.log "New Schedule Overlay created"
		setTemplate: ->
			@template = _.template ScheduleOverlayTmpl
		afterShow: ->
			console.log "Schedule overlay shown"
		selectOption: (e) ->
			option = e.currentTarget.getAttribute 'data-option'
			console.log "Selected option: #{ option }"
			
