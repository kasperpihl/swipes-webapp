define ["view/settings/BaseSubview", "text!templates/settings-snoozes.html"], (BaseView, Tmpl) ->
	BaseView.extend
		className: "snoozes"
		events:
			"click button": "toggleSection"
		setTemplate: ->
			@template = _.template Tmpl
		render: ->
			@$el.html @template { snoozes: swipy.settings.get "snoozes" }
			@transitionIn()
		toggleSection: (e) ->
			$(e.currentTarget.parentNode.parentNode).toggleClass "toggled"