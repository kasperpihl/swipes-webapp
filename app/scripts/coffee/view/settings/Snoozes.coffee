define ["view/settings/BaseSubview", "gsap-draggable", "slider-control", "text!templates/settings-snoozes.html"], (BaseView, Draggable, SliderControl, Tmpl) ->
	BaseView.extend
		className: "snoozes"
		events:
			"click button": "toggleSection"
		initialize: ->
			BaseView::initialize.apply( @, arguments )
			@setupSliders()
		getPercentFromTime: (hour, minute) ->
			0.8
		getSliderVal: (sliderId) ->
			snoozes = swipy.settings.get "snoozes"

			switch sliderId
				when "start-day"
					@getPercentFromTime( snoozes.weekday.morning.hour, snoozes.weekday.morning.minute )
		setupSliders: ->
			startDayOpts = {}
			startDayEl = @el.querySelector ".day .range-slider"
			startDaySlider = new SliderControl( startDayEl, startDayOpts, @getSliderVal "start-day" )
		setTemplate: ->
			@template = _.template Tmpl
		render: ->
			@$el.html @template { snoozes: swipy.settings.get "snoozes" }
			@transitionIn()
		toggleSection: (e) ->
			$(e.currentTarget.parentNode.parentNode).toggleClass "toggled"