define ["text!templates/sidemenu/settings/sidemenu-settings-integrations.html"], (Tmpl) ->
	Backbone.View.extend
		className: "integrations"
		initialize: ->
			@setTemplate()
			@render()
		setTemplate: ->
			@template = _.template Tmpl
		render: ->
			@$el.html @template
		destroy: ->
			@cleanUp()
		cleanUp: ->
			