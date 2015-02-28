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
			if $(e.currentTarget).attr("href") isnt "#"
				return true
			else if identifier is "snoozes-button"
				swipy.router.navigate("settings/snoozes", true)
			else if identifier is "tweaks-button"
				swipy.router.navigate("settings/tweaks", true)
			else if identifier is "sync-button"
				swipy.sync.sync()
			else if identifier is "logout-button"
				if confirm "Are you sure you want to log out?"
					localStorage.clear()
					Parse.User.logOut()
					location.href = "/login/"
			false
		keyUpHandling: (e) ->
			if e.keyCode is 27
				swipy.sidebar.popView()
		render: ->
			@$el.html @template {}
		destroy: ->
			@remove()
		remove: ->
			@undelegateEvents()
			@$el.remove()