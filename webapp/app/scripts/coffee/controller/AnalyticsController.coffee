define ["underscore"], (_) ->
	isInt = (n) ->
		typeof n is 'number' and n % 1 is 0;

	class AnalyticsController
		constructor: ->
			@init()
		init: ->
			@screens = []
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
			user = Parse.user.current()
			cdUserLevel = switch parseInt( user.get( "userLevel" ), 10 )
				when 1 then "Trial"
				when 2 then "Plus Monthly"
				when 3 then "Plus Yearly"
				else "Standard"

			# Update custom dimensions if not standard user
			if cdUserLevel isnt @customDimensions[0]
				@setCustomDimension( 0, cdUserLevel )

			# If user email changed, update the one used by the session
			if user.get( "email" ) isnt @session.customerEmail
				@session.setCustomerEmail user.get "email"

			# If user id changed, update the one used by the session
			if user.id? isnt @session.customerId
				@session.setCustomerId user.id