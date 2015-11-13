define ["underscore"], (_) ->
	isInt = (n) ->
		typeof n is 'number' and n % 1 is 0

	class AnalyticsController
		constructor: ->
			@init()
		init: ->
			@loadedIntercom = false

			@user = swipy.swipesCollections.users.me()

			@startIntercom()
			@updateIdentity()
			Backbone.on("slack-first-connected", @updateIdentity, @)
		startIntercom: ->
			return if !@user?
			return
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
		logEvent: (name, data) ->
			return
			platform = "Web"
			if @isMac?
				platform = "Mac"
			if window.process? and process.versions['electron']
				platform = "Windows"
			amplitude.logEvent(name, data)
		sendEventToIntercom: (eventName, metadata) ->
			return
			Intercom('trackEvent', eventName, metadata )
		updateIdentity: ->
			return
			if @user? and @user.id
				amplitude.setUserId(@user.id)
			
			intercomIdentity = {}
			companyIdentity = {"type": "company"}
			if swipy?
				intercomIdentity["slack_user"] = true
				me = swipy.swipesCollections.users.me()
				activeUsers = swipy.swipesCollections.users.activeUsers()
				intercomIdentity.custom_attributes = {}
				if me
					intercomIdentity.name = me.get("name") if me.get("name")
					intercomIdentity.name = me.get("real_name") if me.get("real_name")
					intercomIdentity.avatar = {type:"avatar", image_url: me.get("profile").image_192} if me.get("profile") and me.get("profile").image_192
					intercomIdentity.custom_attributes.team_mates = activeUsers.length
				companyIdentity.avatar = {type:"avatar", image_url: me.get("profile").image_192} if me.get("profile") and me.get("profile").image_192
				team = swipy.swipesCollections.teams.at(0)
				if team
					companyIdentity.company_id = team.id
					companyIdentity.name = team.get("name") if team.get("name")
					
					companyIdentity.user_count = activeUsers.length
					companyIdentity.total_slack_users = activeUsers.length
					companyIdentity.plan = team.get("plan") if team.get("plan")
					companyIdentity.slack_email_domain = team.get("email_domain") if team.get("email_domain")
					companyIdentity.slack_domain = team.get("domain") if team.get("domain")
				intercomIdentity.companies = [companyIdentity]

			if _.size( intercomIdentity ) > 0
				Intercom("update", intercomIdentity)
