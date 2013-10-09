define ["view/settings/BaseSubview", "text!templates/settings-snoozes.html"], (BaseView, Tmpl) ->
	BaseView.extend
		className: "snoozes"
		events:
			"click button": "toggleSection"
		setTemplate: ->
			@template = _.template Tmpl
		toggleSection: (e) ->
			$(e.currentTarget.parentNode.parentNode).toggleClass "toggled"