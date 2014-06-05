define ["js/view/settings/BaseSubview", "text!templates/settings-support.html"], (BaseView, Tmpl) ->
	BaseView.extend
		className: "support"
		setTemplate: ->
			@template = _.template Tmpl