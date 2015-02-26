define ["underscore", "text!templates/sidemenu/sidemenu-settings.html"], (_, SettingsTmpl) ->
	Backbone.View.extend
		className: "add-sidemenu"
		events:
			"click .grid > a": "clickedGridButton"
		initialize: ->
			@template = _.template SettingsTmpl
			@render()
		clickedGridButton: (e) ->
			identifier = e.currentTarget.id
			if identifier is "support-button"
				return true
			false
		render: ->
			@$el.html @template {}
		destroy: ->
			@remove()
		remove: ->
			@undelegateEvents()
			@$el.remove()