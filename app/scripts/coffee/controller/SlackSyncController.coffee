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
				collection = swipy.slackCollections.groups if channel.is_group
				collection = swipy.slackCollections.ims if channel.is_im

				model = collection.get(channel.id)
				model = collection.create(channel) if !model
				model.save(channel)



		openWebSocket: (url) ->
			@webSocket = new WebSocket(url)
			@webSocket.onopen = @onSocketOpen
			@webSocket.onclose = @onSocketClose
			@webSocket.onmessage = @onSocketMessage
			@webSocket.onerror = @onSocketError


		onSocketOpen: (evt) ->
			console.log evt
		onSocketClose: (evt) ->
			console.log evt.data
		onSocketMessage: (evt) ->
			console.log evt.data
		onSocketError: (evt) ->
			console.log evt.data
		doSocketSend: (message) ->
			console.log evt.data
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