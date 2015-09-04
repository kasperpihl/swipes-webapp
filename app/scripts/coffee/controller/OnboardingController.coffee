define ["underscore", "js/view/modal/WelcomeModal"], (_, WelcomeModal) ->
	class OnboardingController
		constructor: ->
			@currentEvent = localStorage.getItem("OnboardingStatus")
			console.log "current event ", @currentEvent
		start: ->
			@runNextEvent()
		destroy: ->
		getCurrentEvent: ->
			@currentEvent
		setCurrentEvent: (event, next) ->
			@currentEvent = event
			console.log "setting event", event
			localStorage.setItem("OnboardingStatus", event)
			if next
				@runNextEvent()

		runNextEvent: ->
			me = swipy.slackCollections.users.me()
			return if !me
			console.log "running event", @currentEvent
			if !@currentEvent?
				welcomeModal = new WelcomeModal()
				welcomeModal.render()
				welcomeModal.presentModal({opaque: true, closeOnClick: false}, =>
					swipy.router.navigate("im/slackbot",{trigger: true})
					@setCurrentEvent("ShowedWelcome", true)
				)
			else if @currentEvent is "ShowedWelcome"
				setTimeout( =>
					swipy.slackSync.sendMessageAsSlackbot("Hey, fellows. You know what, even bots need love. Meet my awesome girlfriend S.O.F.I. She’s your team collaboration wizard who will also help you to get a hold of your personal workflow.", "@"+me.get("name"), =>
						setTimeout( =>
							swipy.slackSync.sendMessageAsSofi("Hola! Let me just show stuff we can do here. First what would you like to get done today?", "@"+me.get("name"), =>
								@setCurrentEvent("WaitingForMessageToSofi")
							)
						, 2000)
					)
				, 2000)
			else if @currentEvent is "DidSendMessageToSofi"
				setTimeout( =>
					swipy.slackSync.sendMessageAsSofi("Awesome blossom. Now just drag and drop this message to the right to turn it into a task.", "@"+me.get("name"),  =>
						@setCurrentEvent("WaitingForMessageToBeDropped")
					)
				, 1000)
			else if @currentEvent is "DidDropMessage"
				setTimeout( =>
					swipy.slackSync.sendMessageAsSofi("So easy, no? Now just assign someone to take care of it, click on the assign icon in the righthand corner of the task and choose your name.", "@"+me.get("name"),  =>
						@setCurrentEvent("WaitingForAssignment")
					)
				, 1000)
			else if @currentEvent is "DidAssignTask"
				
				setTimeout( =>
					swipy.slackSync.sendMessageAsSofi("Stellar! The best part is that you can check all your tasks in one place. Just click on My tasks in the top left corner.", "@"+me.get("name"),  =>
						@setCurrentEvent("ShowedMyTaskMessage")
					)
				, 1000)