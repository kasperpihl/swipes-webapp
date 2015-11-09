###
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync

###

define ["underscore", "jquery", "js/utility/Utility"], (_, $, Utility) ->
	class SlackSyncController
		constructor: ->
			@token = localStorage.getItem("swipy-token")
			@baseURL = "http://" + document.location.hostname + ":5000/v1/"
			@util = new Utility()
			@currentIdCount = 0
			@sentMessages = {}
			_.bindAll(@, "onSocketMessage", "onSocketClose", "onOpenedWindow")
			Backbone.on("opened-window", @onOpenedWindow, @)
		start: ->
			return if @isStarting?
			@isStarting = true
			@apiRequest("rtm.start", 'GET', {simple_latest: false}, (data, error) =>
				@isStarting = null
				if data and data.ok
					@handleTeam(data.team) if data.team
					@handleSelf(data.self) if data.self
					@handleUsers(data.users) if data.users
					@handleBots(data.bots) if data.bots

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
			collection = swipy.slackCollections.teams
			model = collection.get(team.id)
			model = collection.create(team) if !model
			model.save(team)
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
				@_channelsById[channel.id] = channel
				collection = swipy.slackCollections.channels

				model = collection.get(channel.id)
				model = collection.create(channel) if !model
				model.save(channel)
				if !channel.is_starred
					model.save("is_starred", false)

		clearDeletedChannels: ->
			channelsToDelete = []
			for channel in swipy.slackCollections.channels.models
				if !@_channelsById[channel.id]
					channelsToDelete.push(channel)
			for channel in channelsToDelete
				swipy.slackCollections.channels.remove(channel)
				channel.localStorage = swipy.slackCollections.channels.localStorage
				channel.destroy()
		handleReceivedMessage: (message, incrementUnread) ->
			channel = swipy.slackCollections.channels.get(message.channel)
			channel.addMessage(message, incrementUnread)

		openWebSocket: (url) ->
			#@webSocket = new WebSocket(url)
			@webSocket = io.connect(urlbase, {query: 'token=' + @token});
			@webSocket.on('message', (data) =>
				console.log "message", data
				if data.type is "message"
					message = data.message
					channel = swipy.slackCollections.channels.get(message.channel_id)
					channel.addMessage(message, true)
				else if data.type is "star_added" or data.type is "star_removed"
					if data.data.type is "channel" or data.data.type is "im" or data.data.type is "group"
						targetObj = swipy.slackCollections.channels.get(data.data.channel_id)
					targetObj.save("is_starred", (data.type is "star_added")) if targetObj
			)

		onSocketOpen: (evt) ->
		onSocketClose: (evt) ->
			@webSocket = null if @webSocket?
			@start()
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
				else if data.type is "star_added" or data.type is "star_removed"
					if data.item.type is "channel" or data.item.type is "im" or data.item.type is "group"
						targetObj = swipy.slackCollections.channels.get(data.item.channel)
					targetObj.save("is_starred", (data.type is "star_added")) if targetObj
				else if data.type is "channel_marked" or data.type is "im_marked" or data.type is "group_marked"
					channel = swipy.slackCollections.channels.get(data.channel)
					channel.save("last_read", data.ts)
					channel.save("unread_count_display", data.unread_count_display)
				else if data.type is "channel_joined"
					channel = swipy.slackCollections.channels.get(data.channel.id)
					channel.save(data.channel)
				else if data.type is "channel_left"
					channel = swipy.slackCollections.channels.get(data.channel)
					channel.save("is_member", false)
				else if data.type is "im_close" or data.type is "group_close"
					channel = swipy.slackCollections.channels.get(data.channel)
					channel.save("is_open", false)
				else if data.type is "im_open" or data.type is "group_open"
					channel = swipy.slackCollections.channels.get(data.channel)
					channel.save("is_open", true)

			console.log evt.data
		onSocketError: (evt) ->
			console.log evt
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
			options = {text: message, "channel_id": channel, "user_id":swipy.slackCollections.users.me().id}
			@apiRequest("chat.send", 'POST', options, (res, error) ->
				if res and res.ok
					console.log res if res.fuckyou
					#slackbotChannelId = swipy.slackCollections.channels.slackbot().id
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
		apiRequest: (command, type, options, callback, formData) ->
			url = @baseURL + command
			options = {} if !options? or !_.isObject(options)
			options.token = @token

			options = JSON.stringify(options)

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
				contentType: "application/json; charset=utf-8"
				context: @
				data : options
				processData : true
			if formData
				settings.data = formData
				settings.processData = false
				settings.contentType = false
			#console.log serData
			$.ajax( settings )
