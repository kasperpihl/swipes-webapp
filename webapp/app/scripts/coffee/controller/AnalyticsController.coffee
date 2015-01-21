define ["underscore"], (_) ->
	isInt = (n) ->
		typeof n is 'number' and n % 1 is 0;

	class AnalyticsController
		constructor: ->
			@init()
		init: ->
			analyticsKey = 'UA-XXXX-Y'
			@screens = []
			@customDimensions = {}

			@user = Parse.User.current()
			if @user? and @user.id
				ga('create', analyticsKey, { 'userId' : @user.id } )
			else
				ga('create', analyticsKey, 'auto' )

			ga('send', 'pageview');
			@updateIdentity()

		sendEvent: (category, action, label, value) ->
			ga('send', 'event', category, action, label, value)
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

			