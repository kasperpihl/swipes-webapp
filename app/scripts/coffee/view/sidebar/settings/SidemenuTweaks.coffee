define ["text!templates/sidemenu/settings/sidemenu-settings-tweaks.html"], (Tmpl) ->
	Backbone.View.extend
		className: "tweaks"
		events:
			"click button": "toggleSection"
		initialize: ->
			@setTemplate()
			@render()
		setTemplate: ->
			@template = _.template Tmpl
		render: ->
			settings = swipy.settings.model.toJSON()
			@$el.html @template { settings: settings }
		destroy: ->
			@cleanUp()
		cleanUp: ->
			