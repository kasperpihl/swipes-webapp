define ["underscore", "text!templates/sidemenu/sidemenu-settings.html"], (_, SettingsTmpl) ->
	Backbone.View.extend
		className: "add-sidemenu"
		events:
			"click .settings-links > a": "clickedGridButton"
		initialize: ->
			@template = _.template SettingsTmpl
			@render()
		clickedGridButton: (e) ->
			identifier = e.currentTarget.id
			if identifier is "support-button"
				return true
			else if identifier is "snoozes-button"
				swipy.router.navigate("settings/snoozes", true)
			else if identifier is "tweaks-button"
				swipy.router.navigate("settings/tweaks", true)
			false
		render: ->
			@$el.html @template {}
		destroy: ->
			@remove()
		remove: ->
			@undelegateEvents()
			@$el.remove()