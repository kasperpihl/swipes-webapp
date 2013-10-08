define ["view/settings/BaseSubview", "text!templates/settings-policy.html"], (BaseView, Tmpl) ->
	BaseView.extend
		className: "policy"
		setTemplate: ->
			@template = _.template Tmpl