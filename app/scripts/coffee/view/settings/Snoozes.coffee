define ["view/settings/BaseSubview", "gsap-draggable", "slider-control", "text!templates/settings-snoozes.html"], (BaseView, Draggable, SliderControl, Tmpl) ->
	BaseView.extend
		className: "snoozes"
		events:
			"click button": "toggleSection"
		initialize: ->
			BaseView::initialize.apply( @, arguments )

			_.bindAll( @, "setupSliders", "updateStartDay" )

			@transitionInDfd.then @setupSliders
			
			@listenTo( swipy.settings.model, "change:snoozes", @render )
		getFloatFromTime: (hour, minute) ->
			0.8
		getTimeFromFloat: (val) ->
			hour: 23
			minute: 0
		getSliderVal: (sliderId) ->
			snoozes = swipy.settings.get "snoozes"

			switch sliderId
				when "start-day"
					@getFloatFromTime( snoozes.weekday.morning.hour, snoozes.weekday.morning.minute )
		setupSliders: ->
			startDayOpts = 
				onDrag: @updateStartDay
				onDragEnd: @updateStartDay
			startDayEl = @el.querySelector ".day .range-slider"
			
			@startDaySlider = new SliderControl( startDayEl, startDayOpts, @getSliderVal "start-day" )
		updateStartDay: ->
			console.log @startDaySlider.value
		setTemplate: ->
			@template = _.template Tmpl
		render: ->
			console.log "Rendering snoozes"
			@$el.html @template { snoozes: swipy.settings.get "snoozes" }
			@transitionIn()
		toggleSection: (e) ->
			$(e.currentTarget.parentNode.parentNode).toggleClass "toggled"