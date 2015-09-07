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
				setTimeout( =>
					swipy.slackSync.sendMessageAsSlackbot("Hey, fellows. You know what, even bots need love. Meet my awesome girlfriend s.o.f.i. She’s your team collaboration wizard who will also help you to get a hold of your personal workflow.", "@"+me.get("name"), =>
						setTimeout( =>
							swipy.slackSync.sendMessageAsSofi("Hola! Let me show you the awesome things you can do around here. First, what would you like to get done today?", "@"+me.get("name"), =>
								@setCurrentEvent("WaitingForMessageToSofi")
							)
						, 10)
					)
				, 2000)
			else if @currentEvent is "DidSendMessageToSofi"
				setTimeout( =>
					swipy.slackSync.sendMessageAsSofi("Awesome blossom. Now just drag and drop your own message to the right to turn it into a task.", "@"+me.get("name"),  =>
						@setCurrentEvent("WaitingForMessageToBeDropped")
					)
				, 1000)
				swipy.analytics.logEvent("[Onboard] Wrote Task")
			else if @currentEvent is "DidDropMessage"
				setTimeout( =>
					attachments = JSON.stringify([{"fallback": "Hover a task to see the assign button","image_url":"http://team.swipesapp.com/styles/img/onboard-assign.png"}])
					swipy.slackSync.sendMessageAsSofi("So easy, no? Now assign a person to take care of it by clicking on the assign icon in the righthand corner of the task and select yourself or Slackbot. Though he's probably not getting it done.", "@"+me.get("name"),  =>
						@setCurrentEvent("WaitingForAssignment")
					, attachments)
				, 1000)
				swipy.analytics.logEvent("[Onboard] Dragged Message")
			else if @currentEvent is "DidAssignTask"

				setTimeout( =>
					attachments = JSON.stringify([{"fallback": "Click the top left menu called My Tasks","image_url":"http://team.swipesapp.com/styles/img/onboard-mytasks.png"}])
					swipy.slackSync.sendMessageAsSofi("To see your assigned tasks, just click on My tasks in the top left corner.", "@"+me.get("name"),  =>
						@setCurrentEvent("WaitingForMyTasks")
					, attachments)
				, 1000)
				swipy.analytics.logEvent("[Onboard] Assigned Task")
			else if @currentEvent is "DidOpenMyTasks"
				setTimeout( =>
					attachments = JSON.stringify([{"fallback": "In My Tasks, you can use the schedule and complete buttons to remove notifications","image_url":"http://team.swipesapp.com/styles/img/onboard-schedule-complete.png"}])
					swipy.slackSync.sendMessageAsSofi("Stellar! You can remove the notifications from My Tasks by either completing or scheduling your current tasks for later. That's it from me for now.", "@"+me.get("name"),  =>
						@setCurrentEvent("WaitingForNext")
					, attachments)
				, 3000)
				swipy.analytics.logEvent("[Onboard] Opened My Tasks")
				swipy.analytics.logEvent("[Onboard] Completed")