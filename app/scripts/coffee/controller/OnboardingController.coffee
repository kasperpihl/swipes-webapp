define ["underscore", "js/view/modal/WelcomeModal"], (_, WelcomeModal) ->
	class OnboardingController
		constructor: ->
			@currentEvent = localStorage.getItem("OnboardingStatus")
		start: ->
			@runNextEvent()
		destroy: ->
		getCurrentEvent: ->
			@currentEvent
		setCurrentEvent: (event, next) ->
			@currentEvent = event
			localStorage.setItem("OnboardingStatus", event)
			if next
				@runNextEvent()
		runNextEvent: ->
			me = swipy.slackCollections.users.me()
			return if !me
			if !@currentEvent?
				attachments = JSON.stringify([{"fallback": "Invite people to Swipes","title": "Invite colleagues to collaborate with Swipes", "title_link":"http://swipesapp.com/forward?dest=invite-popup"}])
				setTimeout( =>
					swipy.slackSync.sendMessageAsSofi("Hola! Lovely to meet you. I’m your collaboration bot and would love to help you out around here.\r\n\r\nWorking alone is a bummer. Why not bring your whole team in here? It’s going to be more fun - plus you’ll get more done together.", "@"+me.get("name"), =>
						@setCurrentEvent("DidSendWelcomeMessage")
						swipy.analytics.logEvent("[Onboard] Welcome Message Sent")
					, attachments)
				, 2000)