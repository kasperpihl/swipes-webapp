define ["underscore", "backbone", "view/Overlay", "text!templates/schedule-overlay.html"], (_, Backbone, Overlay, ScheduleOverlayTmpl) ->
	Overlay.extend
		className: 'overlay scheduler'
		events: 
			"click .grid > a": "selectOption"
		bindEvents: ->
			_.bindAll( @, "handleResize" )
			$(window).on( "resize", @handleResize )
		init: ->
			console.log "New Schedule Overlay created"
		setTemplate: ->
			@template = _.template ScheduleOverlayTmpl
		afterShow: ->
			console.log "Schedule overlay shown"
			@handleResize()
		selectOption: (e) ->
			option = e.currentTarget.getAttribute 'data-option'
			console.log "Selected option: #{ option }"
		handleResize: ->
			return unless @shown
			
			content = @$el.find ".overlay-content"
			offset = ( window.innerHeight / 2 ) - ( content.height() / 2 )
			content.css( "margin-top", offset )
		cleanUp: ->
			$(window).off()

			# Same as super() in real OOP programming
			Overlay::cleanUp.apply( @, arguments )
			
