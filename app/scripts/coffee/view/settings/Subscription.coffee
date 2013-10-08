define ["view/settings/BaseSubview", "text!templates/settings-subscription.html"], (BaseView, Tmpl) ->
	BaseView.extend
		className: "subscription"
		setTemplate: ->
			@template = _.template Tmpl