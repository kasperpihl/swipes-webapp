define ["js/view/settings/BaseSubview", "text!templates/settings-policies.html"], (BaseView, Tmpl) ->
	BaseView.extend
		className: "policy"
		setTemplate: ->
			@template = _.template Tmpl