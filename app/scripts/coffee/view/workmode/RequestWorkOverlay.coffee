define ["underscore" 
		"js/view/Overlay"
		"text!templates/request-work-overlay.html"
		"gsap-draggable"
		"slider-control"
	], (_, Overlay, RequestWorkOverlayTmpl, Draggable, SliderControl) ->
	Overlay.extend
		className: 'overlay request-work'
		events:
			"click .overlay-bg": "destroy"
		initialize: ->
			_.bindAll( @, "updateValue" )
			if arguments[ 0 ]
				@options = arguments[ 0 ]
			Overlay::initialize.apply( @, arguments )
			@showClassName = "request-work-open"
			@hideClassName = "hide-request-work"
			@render()

		bindEvents: ->
			_.bindAll( @, "handleResize" )
			$(window).on( "resize", @handleResize )
		setTemplate: ->
			@template = _.template RequestWorkOverlayTmpl
		getOpts: ->
			{ onDrag: @updateValue, onDragEnd: @updateValue, steps: (2 * 12) + 1  }
		updateValue: ->
			numberOfMinutes = Math.ceil(@slider.value * ( 2 * 60 ))

			hours = Math.floor(numberOfMinutes/60)
			if hours < 10
				hours = "0" + hours
			minutes = Math.round(numberOfMinutes) % 60
			if minutes < 10
				minutes = "0"+minutes
			string = "" + hours + ":" + minutes
			@$el.find(".time-label").html string
		render: () ->
			@$el.html @template()
			if not $("body").find(".overlay.request-work").length
				$("body").append @$el
			console.log @$el.find(".range-slider").get(0)
			

			@show()
			@handleResize()
			return @
		afterShow: ->
			swipy.shortcuts.lock()
			@slider = new SliderControl( @$el.find(".range-slider").get(0), @getOpts(), 0.5 )
			@updateValue()
		afterHide: ->
			swipy.shortcuts.unlock()
		handleResize: ->
			return unless @shown

			content = @$el.find ".overlay-content"
			offset = ( window.innerHeight / 2 ) - ( content.height() / 2 )
			content.css( "margin-top", offset )
		cleanUp: ->
			$(window).off("resize", @handleResize)

			# Same as super() in real OOP programming
			Overlay::cleanUp.apply( @, arguments )
