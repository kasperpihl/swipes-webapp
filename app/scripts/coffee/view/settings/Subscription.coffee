define ["view/settings/BaseSubview", "text!templates/settings-subscription.html"], (BaseView, Tmpl) ->
	BaseView.extend
		setTemplate: ->
			@template = _.template Tmpl