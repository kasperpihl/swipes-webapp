define ["underscore", "backbone", "view/Overlay", "text!templates/schedule-overlay.html"], (_, Backbone, Overlay, ScheduleOverlayTmpl) ->
	Overlay.extend
		className: 'overlay scheduler'
		events:
			"click .grid > a:not(.disabled)": "selectOption"
			"click .overlay-bg": "hide"
		initialize: ->
			Overlay::initialize.apply( @, arguments )

			@showClassName = "scheduler-open"
			@hideClassName = "hide-scheduler"
		bindEvents: ->
			_.bindAll( @, "handleResize" )
			$(window).on( "resize", @handleResize )
		setTemplate: ->
			@template = _.template ScheduleOverlayTmpl
		render: ->
			if @template
				html = @template @model.toJSON()
				@$el.html html

			return @
		afterShow: ->
			@handleResize()
		selectOption: (e) ->
			option = e.currentTarget.getAttribute 'data-option'
			Backbone.trigger( "pick-schedule-option", option )
		hide: (cancelled = yes) ->
			if cancelled and @currentTasks?
				Backbone.trigger( "scheduler-cancelled", @currentTasks )

			Overlay::hide.apply( @, arguments )
		handleResize: ->
			return unless @shown

			content = @$el.find ".overlay-content"
			offset = ( window.innerHeight / 2 ) - ( content.height() / 2 )
			content.css( "margin-top", offset )
		cleanUp: ->
			$(window).off( "resize", @handleResize )

			# Same as super() in real OOP programming
			Overlay::cleanUp.apply( @, arguments )

