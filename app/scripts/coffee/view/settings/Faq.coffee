define ["view/settings/BaseSubview", "text!templates/settings-faq.html"], (BaseView, Tmpl) ->
	BaseView.extend
		className: "faq"
		setTemplate: ->
			@template = _.template Tmpl