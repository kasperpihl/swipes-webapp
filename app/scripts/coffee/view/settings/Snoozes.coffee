define ["view/settings/BaseSubview", "text!templates/settings-snoozes.html"], (BaseView, Tmpl) ->
	BaseView.extend
		className: "snoozes"
		setTemplate: ->
			@template = _.template Tmpl