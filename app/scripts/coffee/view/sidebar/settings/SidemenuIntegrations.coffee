define ["underscore", "jquery", "text!templates/sidemenu/settings/sidemenu-settings-integrations.html"], (_, $, Tmpl) ->
	Backbone.View.extend
		className: "integrations"
		events:
			"click .integrations-settings > a": "addIntegration"
		initialize: ->
			@setTemplate()
			@render()
		addIntegration: (e) ->
			buttonIdentifier = e.currentTarget.id
			if buttonIdentifier is "evernote-button"
				alert "Evernote Integration will be coming to all platforms this fall. Please use the Evernote integration on iOS or Android for now"
			else if buttonIdentifier is "email-button"
				connectURL = "https://connect.context.io/api/2.0/connect_tokens/huer853f4w4hyq57?developer_key=54cf9515f1620c2a223ac2f9&branding_url=https%253A%252F%252Fs3.amazonaws.com%252Fcontextioconnect%252F54cf9515f1620c2a223ac2f9%252F1435037649&branding_width=100&branding_height=100&branding_tagline=Swipes"
				window.open(connectURL)
				###swipy.api.callAPI(
					"mailbox",
					"POST",
					{"callback_url": "http://localhost:9000#settings/integrations"}, 
					(res, err) ->
						if( res )
						console.log res
						console.log err
				)###
			false
		setTemplate: ->
			@template = _.template Tmpl
		render: ->
			@$el.html @template
		destroy: ->
			@cleanUp()
		cleanUp: ->
			