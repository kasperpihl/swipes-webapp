define ["underscore"], (_) ->
	isInt = (n) ->
		typeof n is 'number' and n % 1 is 0;

	class AnalyticsController
		constructor: ->
			@init()
		init: ->
			analyticsKey = 'UA-41592802-4'
			@screens = []
			@customDimensions = {}
			@loadedIntercom = false

			@user = Parse.User.current()
			if @user? and @user.id
				ga('create', analyticsKey, { 'userId' : @user.id } )
			else
				ga('create', analyticsKey, 'auto' )

			ga('send', 'pageview');
			@startIntercom()
			@updateIdentity()
		startIntercom: ->
			return if !@user?
			userId = @user.id

			if @validateEmail @user.get("username")
				email = @user.get("username")
			else if @validateEmail @user.get("email")
				email = @user.get("email")
			
			window.Intercom('boot', {
				app_id: 'yobuz4ff'
				email: email
				user_id: userId
				createdAt: parseInt(@user.createdAt.getTime()/1000,10)
			})
			@loadedIntercom = true
		validateEmail: (email) ->
			regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
			regex.test email
		sendEvent: (category, action, label, value) ->
			ga('send', 'event', category, action, label, value)
		sendEventToIntercom: (eventName, metadata) ->
			Intercom('trackEvent', eventName, metadata )
		pushScreen: (screenName) ->
			ga('send', 'screenview', {
  				'screenName': screenName
			})
			@screens.push screenName
		popScreen: ->
			if @screens.length
				@screens.pop()
				lastScreen = _.last @screens
				return if !lastScreen?
				ga('send', 'screenview', {
  					'screenName': lastScreen
				})
		updateIdentity: ->
			gaSendIdentity = {}


			userLevel = "None"
			if @user?
				userLevel = "User"
				numberUserLevel = parseInt( @user.get( "userLevel" ), 10 )
				if numberUserLevel > 1
					userLevel = "Plus"

			currentUserLevel = @customDimensions['user_level']
			if currentUserLevel isnt userLevel
				gaSendIdentity["dimension1"] = userLevel


			theme = "Light"
			currentTheme = @customDimensions['active_theme']
			if currentTheme isnt theme
				gaSendIdentity['dimension3'] = theme

			if swipy?
				recurringTasks = swipy.todos.filter (m) -> m.get("repeatOption") isnt "never"
				recurringCount = recurringTasks.length
				currentRecurringCount = @customDimensions['recurring_tasks']
				if currentRecurringCount isnt recurringCount
					gaSendIdentity['dimension4'] = recurringCount

				numberOfTags = swipy.tags.length
				currentNumberOfTags = @customDimensions['number_of_tags']
				if currentNumberOfTags isnt numberOfTags
					gaSendIdentity['dimension5'] = numberOfTags

			if _.size( gaSendIdentity ) > 0
				ga('set', gaSendIdentity)
				@sendEvent("Session", "Updated Identity")

