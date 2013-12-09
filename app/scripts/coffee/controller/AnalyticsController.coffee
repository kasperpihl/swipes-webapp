define ["underscore"], (_) ->
	isInt = (n) ->
		typeof n is 'number' and n % 1 is 0;

	class AnalyticsController
		constructor: ->
			@init()
		init: ->
			@customDimensions = ["Standard"]
			@screens = []
			@createSession()
		createSession: ->
			@session = LocalyticsSession @getKey()
			@session.open()
			@session.upload()
			@setUser Parse.User.current()
		getKey: ->
			testKey = "f2f927e0eafc7d3c36835fe-c0a84d84-18d8-11e3-3b24-00a426b17dd8"
			liveKey = "0c159f237171213e5206f21-6bd270e2-076d-11e3-11ec-004a77f8b47f"
			# Figure out which one to use here...
			return testKey
		hasDimension: (dimension) ->
			if isInt( dimension ) and @customDimensions.length < dimension >= 0
				return true
			else return false
		customDimension: (dimension) ->
			if @hasDimension dimension
				return @customDimensions[dimension]
			else
				return false
		setCustomDimension: (dimension, value) ->
			if @hasDimension dimension
				@customDimensions[dimension] = value
		tagEvent: (ev, options) ->
			@session.tagEvent( ev, options, @customDimensions )
		pushScreen: (screenName) ->
			@session.tagScreen screenName
			@screens.push screenName
		popScreen: ->
			if @screens.length
				@screens.pop()
				@session.tagScreen _.last @screens
		setUser: (user) ->
			cdUserLevel = switch parseInt( user.get( "userLevel" ), 10 )
				when 1 then "Trial"
				when 2 then "Plus Monthly"
				when 3 then "Plus Yearly"
				else "Standard"

			# Update custom dimensions if not standard user
			if cdUserLevel isnt @customDimensions[0]
				@setCustomDimension( 0, cdUserLevel )

			# If user email changed, update the one used by the session
			if user.get( "email" ) isnt @createSession().customerEmail
				@session.setCustomerEmail user.get "email"

			# If user id changed, update the one used by the session
			if user.id? isnt @session.customerId
				@session.setCustomerId user.id