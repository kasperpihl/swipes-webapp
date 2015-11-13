###
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync

###

define ["underscore", "jquery", "js/utility/Utility"], (_, $, Utility) ->
	class SwipesSyncController
		constructor: ->
			@token = localStorage.getItem("swipy-token")
			@baseURL = "http://" + document.location.hostname + ":5000/v1/"
			@util = new Utility()
			@currentIdCount = 0
			@sentMessages = {}
			@listeners = {}

			_.bindAll(@, "onOpenedWindow")
			Backbone.on("opened-window", @onOpenedWindow, @)
		start: ->
			return if @isStarting?
			@isStarting = true
			@apiRequest("rtm.start", {simple_latest: false}, (data, error) =>
				@isStarting = null
				if data and data.ok
					@handleTeam(data.team) if data.team
					@handleSelf(data.self) if data.self
					@handleUsers(data.users) if data.users
					@handleApps(data.apps) if data.apps

					@_channelsById = {}
					@handleChannels(data.channels) if data.channels
					@handleChannels(data.groups) if data.groups
					@handleChannels(data.ims) if data.ims
					# Only enable threaded conversations for Swipes Team
					#if data.team.id is "T02A53ZUJ"
						# T_TODO disabling threds. There are still comments when you try to type from the edit view
						#localStorage.setItem("EnableThreadedConversations", true)
					@clearDeletedChannels()
					@openWebSocket(data.url)
					localStorage.setItem("slackLastConnected", new Date())
					Backbone.trigger('slack-first-connected')
			)
		handleTeam: (team) ->
			collection = swipy.swipesCollections.teams
			model = collection.get(team.id)
			model = collection.create(team) if !model
			model.save(team)
		handleSelf:(self) ->
			collection = swipy.swipesCollections.users
			model = collection.get(self.id)
			model = collection.create(self) if !model
			model.set("me",true)
			model.save(self)
		handleUsers:(users) ->
			collection = swipy.swipesCollections.users
			for user in users
				model = collection.get(user.id)
				model = collection.create(user) if !model
				model.save(user)
		handleApps: (apps) ->
			collection = swipy.swipesCollections.apps
			for app in apps
				model = collection.get(app.id)
				model = collection.create(app) if !app
				model.save(app)
		handleChannels: (channels) ->
			collection = swipy.swipesCollections.channels
			for channel in channels
				@_channelsById[channel.id] = channel

				model = collection.get(channel.id)
				model = collection.create(channel) if !model
				model.save(channel)
				if !channel.is_starred
					model.save("is_starred", false)

		clearDeletedChannels: ->
			channelsToDelete = []
			for channel in swipy.swipesCollections.channels.models
				if !@_channelsById[channel.id]
					channelsToDelete.push(channel)
			for channel in channelsToDelete
				swipy.swipesCollections.channels.remove(channel)
				channel.localStorage = swipy.swipesCollections.channels.localStorage
				channel.destroy()
		handleReceivedMessage: (message, incrementUnread) ->
			channel = swipy.swipesCollections.channels.get(message.channel)
			channel.addMessage(message, incrementUnread)

		openWebSocket: (url) ->
			#@webSocket = new WebSocket(url)
			@webSocket = io.connect(urlbase, {query: 'token=' + @token});
			console.log "opening websocket"
			@webSocket.on('message', (data) =>
				console.log "message", data
				if data.type is "message"
					message = data.message
					channel = swipy.swipesCollections.channels.get(message.channel_id)
					channel.addMessage(message, true)
				else if data.type is "star_added" or data.type is "star_removed"
					if data.data.type is "channel" or data.data.type is "im" or data.data.type is "group"
						targetObj = swipy.swipesCollections.channels.get(data.data.channel_id)
					targetObj.save("is_starred", (data.type is "star_added")) if targetObj
				if @listeners[data.type]
					@listeners[data.type].callListener("event", data)
			)

		doSocketSend: (message, dontSave) ->
			if _.isObject(message)
				message.id = ++@currentIdCount
				@sentMessages[""+message.id] = message if !dontSave
				message = JSON.stringify(message)
			@webSocket?.send(message)
		onOpenedWindow: ->
			if !@webSocket?
				@start()
		sendMessage:(message, channel, callback) ->
			self = @
			console.log channel
			options = {text: message, "channel_id": channel, "user_id":swipy.swipesCollections.users.me().id}
			@apiRequest("chat.send", options, (res, error) ->
				if res and res.ok
					console.log res if res.fuckyou
					#slackbotChannelId = swipy.swipesCollections.channels.slackbot().id
					#type = self.util.slackTypeForId(channel)
					#if type is "DM" and channel is slackbotChannelId
					#	type = "Slackbot"
					#swipy.analytics.logEvent("[Engagement] Sent Message", {"Type": type})
					#swipy.analytics.sendEventToIntercom( 'Sent Message', {"Type": type} )
				callback?(res, error)
			)
		uploadFile: (channels, file, callback, initialComment) ->
			formData = new FormData()
			formData.append("token", @token)
			formData.append("channels", channels)
			formData.append("filename", file.name)
			formData.append("file", file);
			swipy.analytics.logEvent("[Engagement] Upload File Started", {})
			@apiRequest("files.upload", 'POST', {}, (res, error) ->
				if res and res.ok
					swipy.analytics.logEvent("[Engagement] Uploaded File", {} )
					swipy.analytics.sendEventToIntercom( 'Uploaded File', {} )
				callback?(res,error)
			, formData)
		sendMessageAsSofi: (message, channel, callback, attachments) ->
			options = {text: message, channel: channel, as_user: false, link_names: 1, username: "s.o.f.i.", icon_url: "http://team.swipesapp.com/styles/img/sofi48.jpg"}
			options.attachments = attachments if attachments
			@apiRequest("chat.postMessage", 'POST', options, (res, error) ->
				callback?(res, error)
			)
		connectorHandleResponseReceivedFromListener: (connector, message, callback) ->
			if message and message.command
				data = message.data
				if message.command is "navigation.setTitle"
					swipy.topbarVC.setTitle(data.title, false ) if data.title
				else if message.command is "navigation.setBackgroundColor"
					swipy.topbarVC.setBackgroundColor(data.color)
				else if message.command is "navigation.setForegroundColor"
					swipy.topbarVC.setForegroundColor(data.color)
				else if message.command is "navigation.enableBoxShadow"
					swipy.topbarVC.enableBoxShadow(data.enable)
				else if message.command is "users.get"
					if data.id
						callback(swipy.swipesCollections.users.get(data.id))
				else if message.command is "listenTo"
					@listeners[data.event] = connector


		apiRequest: (options, data, callback, formData) ->
			swipy.api.callSwipesApi(options, data, callback, formData)
