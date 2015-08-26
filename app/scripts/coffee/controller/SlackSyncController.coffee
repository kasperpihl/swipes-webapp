###
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync

###

define ["underscore", "jquery", "js/utility/Utility"], (_, $, Utility) ->
	class SlackSyncController
		constructor: ->
			@token = localStorage.getItem("slack-token")
			@baseURL = "https://slack.com/api/"
			@util = new Utility()
			@currentIdCount = 0
			@sentMessages = {}
			_.bindAll(@, "onSocketMessage")
		start: ->
			@apiRequest("rtm.start", {simple_latest: false}, (data, error) =>
				if data and data.ok
					@handleSelf(data.self) if data.self
					@handleUsers(data.users) if data.users
					@handleBots(data.bots) if data.bots
					@handleChannels(data.channels) if data.channels
					@handleChannels(data.groups) if data.groups
					@handleChannels(data.ims) if data.ims
					@openWebSocket(data.url)
					localStorage.setItem("slackLastConnected", new Date())
					Backbone.trigger('slack-first-connected')
					
			)
		handleSelf:(self) ->
			collection = swipy.slackCollections.users
			model = collection.get(self.id)
			model = collection.create(self) if !model
			model.set("me",true)
			model.save(self)
		handleUsers:(users) ->
			for user in users
				collection = swipy.slackCollections.users
				model = collection.get(user.id)
				model = collection.create(user) if !model
				model.save(user)
		handleBots:(bots) ->
			for bot in bots
				collection = swipy.slackCollections.bots
				model = collection.get(bot.id)
				model = collection.create(bot) if !model
				model.save(bot)
		handleChannels: (channels) ->
			for channel in channels
				collection = swipy.slackCollections.channels

				model = collection.get(channel.id)
				model = collection.create(channel) if !model
				model.save(channel)

		handleReceivedMessage: (message, incrementUnread) ->
			channel = swipy.slackCollections.channels.get(message.channel)
			channel.addMessage(message, incrementUnread)

		openWebSocket: (url) ->
			@webSocket = new WebSocket(url)
			@webSocket.onopen = @onSocketOpen
			@webSocket.onclose = @onSocketClose
			@webSocket.onmessage = @onSocketMessage
			@webSocket.onerror = @onSocketError


		onSocketOpen: (evt) ->
		onSocketClose: (evt) ->
			console.log evt
		onSocketMessage: (evt) ->
			if evt and evt.data
				
				data = JSON.parse(evt.data)
				# Reply to sent data over websocket
				if data.ok and data.reply_to
					sentMessage = @sentMessages[""+data.reply_to]
					return if !sentMessage?
					if sentMessage.type is "message"
						sentMessage.ts = data.ts
						delete sentMessage["id"]
						@handleReceivedMessage(sentMessage)
						delete @sentMessages[""+data.reply_to]
					return
				if data.type is "presence_change"
					user = swipy.slackCollections.users.get(data.user)
					user.save("presence", data.presence)
				else if data.type is "message"
					@handleReceivedMessage(data, true)
				else if data.type is "channel_marked" or data.type is "im_marked" or data.type is "group_marked"
					channel = swipy.slackCollections.channels.get(data.channel)
					channel.save("last_read", data.ts)
					channel.save("unread_count_display", data.unread_count_display)

			console.log evt.data
		onSocketError: (evt) ->
			console.log evt
		doSocketSend: (message, dontSave) ->
			if _.isObject(message)
				message.id = ++@currentIdCount
				@sentMessages[""+message.id] = message if !dontSave
				message = JSON.stringify(message)
			@webSocket.send(message)

		sendMessage:(message, channel) ->
			options = {text: message, channel: channel, as_user: true, link_names: 1}
			@apiRequest("chat.postMessage", options, (res, error) ->

			)
		apiRequest: (command, options, callback) ->
			url = @baseURL + command
			options = {} if !options? or !_.isObject(options)
			options.token = @token

			settings = 
				url : url
				type : 'POST'
				success : ( data ) ->
					console.log "slack success", data
					if data and data.ok
						callback?(data);
					else
						@util.sendError( data, "Sync Error" )
						callback?(false, data);
				error : ( error ) ->
					console.log "slack error", error
					@util.sendError( error, "Server Error")
					callback?(false, error)
				crossDomain : true
				context: @
				data : options
				processData : true
			#console.log serData
			$.ajax( settings )