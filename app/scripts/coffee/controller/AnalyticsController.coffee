define ["underscore"], (_) ->
	isInt = (n) ->
		typeof n is 'number' and n % 1 is 0

	class AnalyticsController
		constructor: ->
			@init()
		init: ->
			@loadedIntercom = false

			@user = swipy.slackCollections.users.me()

			@startIntercom()
			@updateIdentity()
		startIntercom: ->
			return if !@user?
			userId = @user.id

			if @validateEmail @user.get("profile").email
				email = @user.get("profile").email
			
			window.Intercom('boot', {
				app_id: 'yobuz4ff'
				email: email
				user_id: userId
			})
			@loadedIntercom = true
		validateEmail: (email) ->
			regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
			regex.test email
		sendEvent: (category, action, label, value) ->
			platform = "Web"
			if @isMac?
				platform = "Mac"
			ga('set', {"dimension7": platform})
			ga('send', 'event', category, action, label, value)
		logEvent: (name, data) ->
			amplitude.logEvent(name, data)
		sendEventToIntercom: (eventName, metadata) ->
			Intercom('trackEvent', eventName, metadata )
		updateIdentity: ->
			if @user? and @user.id
				amplitude.setUserId(@user.id)
				
			intercomIdentity = {}
			if swipy?
				intercomIdentity["slack_user"] = true

			if _.size( intercomIdentity ) > 0
				Intercom("update", intercomIdentity)

