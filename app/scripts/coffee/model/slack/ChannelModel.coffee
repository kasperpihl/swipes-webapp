define ["underscore", "js/collection/slack/MessageCollection"], (_, MessageCollection) ->
	Backbone.Model.extend
		className: "Channel"
		excludeFromJSON: [ "messages" ]
		initialize: ->
			messageCollection = new MessageCollection()
			messageCollection.localStorage = new Backbone.LocalStorage("MessageCollection-" + @id )
			messageCollection.fetch()
			@set("messages", messageCollection)
		getName: ->
			return @get("name") if @get("name")
			if @get("user") and swipy.slackCollections and swipy.slackCollections.users.get(@get("user"))
				return swipy.slackCollections.users.get(@get("user")).get("name")
		getApiType: ->
			apiType = "channels"
			if @get("is_im")
				apiType = "im"
			if @get("is_group")
				apiType = "groups"
			apiType
		fetchMessages: (collection) ->
			options = {channel: @id, count: 50 }
			
			collection = @get("messages")
			collection.fetch()
			if collection.models.length
				lastModel = collection.at(collection.models.length-1)
				options.oldest = lastModel.get("ts")
			swipy.slackSync.apiRequest(@getApiType() + ".history",options, 
				(res, error) =>
					if res and res.ok
						@hasFetched = true
						for message in res.messages
							@addMessage(message)
			)
		addMessage: (message, increment) ->
			collection = @get("messages")
			if !collection.get(message.ts)

				if swipy.onboarding.getCurrentEvent() is "WaitingForMessageToSofi" and @id is swipy.slackCollections.channels.slackbot().id and message.user is swipy.slackCollections.users.me().id
					swipy.onboarding.setCurrentEvent("DidSendMessageToSofi", true)
				if increment and message.user isnt swipy.slackCollections.users.me().id
					@save("unread_count_display", @get("unread_count_display")+1)
					if @get("is_im")
						if !swipy.bridge.bridge # OR you were mentioned in the task /TODO:
							Backbone.trigger("play-new-message")
						else
							text = "You received 1 new message"
							text = message.text if message.text
							title = "[Swipes] " + @getName() 
							swipy.bridge.callHandler("notify",{title: title, message: text})
				return if(!@hasFetched? or !@hasFetched)
				newMessage = collection.create( message )

		markAsRead: ->
			collection = @get("messages")
			options = {channel: @id }
			if collection.models.length
				lastModel = collection.at(collection.models.length-1)
				options.ts = lastModel.get("ts")
			swipy.slackSync.apiRequest(@getApiType() + ".mark",options, 
				(res, error) =>
					if res and res.ok
						console.log "marked"
					else
						console.log error
			)