define ->
	class SliderControl
		constructor: (@el, opts, value = 0) ->
			@cacheElements()
			@proxyCallbacks opts
			@opts = $.extend( @getDefaultOptions(), opts )

			if opts.steps
				@opts.stepCount = opts.steps
				@opts.liveSnap = @getPxSteps()

				# add opts.liveSteps?

			@init()

			$(window).on( "resize.slidercontrol", @handleResize )
			@handleResize()

			@setValue( value, value > 0, no )

		cacheElements: ->
			@track = @el.querySelector ".track"
			@handle = @el.querySelector ".handle"

		proxyCallbacks: (opts) ->
			if opts?.onDrag
				@onDragCb = opts.onDrag
				delete opts.onDrag

			if opts?.onDragEnd
				@onDragEndCb = opts.onDragEnd
				delete opts.onDragEnd

		handleResize: =>
			@draggable.vars.bounds = { minX: 0, maxX: @getBounds().width + 1 }
			if @opts.stepCount
				steps = @getPxSteps()
				@draggable.vars.liveSnap = steps

			# Update position of handle
			@setValue @value

		getDefaultOptions: ->
			type: "x"
			zIndexBoost: no
			bounds: { minX: 0, maxX: @getBounds().width + 1 }
			onDrag: @handleDrag
			onDragScope: @
			onDragEnd: @handleDragEnd
			onDragEndScope: @

		init: ->
			@draggable = new Draggable( @handle, @opts )

		getBounds: ->
			@track.getBoundingClientRect()

		getClosestValue: (value) ->
			steps = @getValueSteps()
			diffs = ( Math.abs( value - step ) for step in steps )
			minDist = Math.min diffs...

			return steps[i] for val, i in diffs when val is minDist
		getValueSteps: ->
			if not @valueSteps
				incrementBy = 1 / ( @opts.stepCount - 1 )
				@valueSteps = ( incrementBy * i for i in [0...@opts.stepCount] )
				@valueSteps
			else
				@valueSteps

		getPxSteps: ->
			for step in @getValueSteps()
				switch step
					when 0 then step
					when 1 then Math.round @getBounds().width
					else Math.round @convertFloatToPx( step )

		getValueFromPxStep: (px) ->
			for val, i in @opts.liveSnap when val is px
				@currentStep = i
				matchingValue = @getValueSteps()[i]
				return matchingValue

		convertFloatToPx: (float) ->
			@track.clientWidth * float

		convertPxToFloat: (px) ->
			px / @track.clientWidth

		# Drag logic
		handleDrag: ->
			@value = @getSlideValue()
			if @onDragCb then @onDragCb.apply( @, arguments )

		handleDragEnd: ->
			@value = @getSlideValue()
			if @onDragEndCb then @onDragEndCb.apply( @, arguments )

		getSlideValue: ->
			if @opts.stepCount
				return @getValueFromPxStep @draggable.x
			else
				val = @draggable.x / @track.clientWidth
				return Math.min( Math.max( val, 0), 1 )

		setValue: (value, updateDraggable = yes, pxValue = no) ->
			if pxValue
				@value = @convertPxToFloat value
			else
				@value = value
				value = @convertFloatToPx value

			TweenLite.set( @handle, { x: value } )

			if updateDraggable then @draggable.update()

			return @value

		# Memory management
		disable: ->
			$(window).off( "resize.slidercontrol", @handleResize )
			@draggable.disable()

		enable: ->
			@draggable.enable()
			$(window).on( "resize.slidercontrol", @handleResize )
			@handleResize()

		destroy: ->
			@disable()