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
				welcomeModal = new WelcomeModal()
				welcomeModal.render()
				welcomeModal.presentModal({opaque: true, closeOnClick: false}, =>
					swipy.router.navigate("im/slackbot",{trigger: true})
					@setCurrentEvent("ShowedWelcome", true)
				)
			else if @currentEvent is "ShowedWelcome"
				setTimeout( =>
					swipy.slackSync.sendMessageAsSlackbot("Hey, fellows. You know what, even bots need love. Meet my awesome girlfriend s.o.f.i. She’s your team collaboration wizard who will also help you to get a hold of your personal workflow.", "@"+me.get("name"), =>
						setTimeout( =>
							swipy.slackSync.sendMessageAsSofi("Hola! Let me show you the awesome things you can do around here. First, what would you like to get done today?", "@"+me.get("name"), =>
								@setCurrentEvent("WaitingForMessageToSofi")
							)
						, 2000)
					)
				, 2000)
			else if @currentEvent is "DidSendMessageToSofi"
				setTimeout( =>
					swipy.slackSync.sendMessageAsSofi("Awesome blossom. Now just drag and drop your own message to the right to turn it into a task.", "@"+me.get("name"),  =>
						@setCurrentEvent("WaitingForMessageToBeDropped")
					)
				, 1000)
			else if @currentEvent is "DidDropMessage"
				setTimeout( =>
					swipy.slackSync.sendMessageAsSofi("So easy, no? Now assign a person to take care of it by clicking on the assign icon in the righthand corner of the task and select yourself or Slackbot. Though he's probably not getting it done.", "@"+me.get("name"),  =>
						@setCurrentEvent("WaitingForAssignment")
					)
				, 1000)
			else if @currentEvent is "DidAssignTask"
				
				setTimeout( =>
					swipy.slackSync.sendMessageAsSofi("To see your assigned tasks, just click on My tasks in the top left corner.", "@"+me.get("name"),  =>
						@setCurrentEvent("WaitingForMyTasks")
					)
				, 1000)
			else if @currentEvent is "DidOpenMyTasks"
				setTimeout( =>
					swipy.slackSync.sendMessageAsSofi("Stellar! You can remove the notifications from My Tasks by either completing or scheduling your current tasks for later. That's it from me for now.", "@"+me.get("name"),  =>
						@setCurrentEvent("WaitingForNext")
					)
				, 3000)