define ["underscore", "js/collection/slack/MessageCollection", "collectionSubset"], (_, MessageCollection) ->
	Backbone.Model.extend
		className: "Channel"
		excludeFromJSON: [ "messages" ]
		skipCount: 100
		initialize: ->
			messageCollection = new MessageCollection()
			messageCollection.localStorage = new Backbone.LocalStorage("MessageCollection-" + @id )
			messageCollection.fetch()
			@set("messages", messageCollection)
		getMessages: ->
			messages = @getMessageCollection()
			loop
				break if messages.length <= @skipCount
				first = messages.shift()
				first.localStorage = messages.localStorage
				first.destroy()
			messages
		getMessageCollection: ->
			messages = @get("messages")
			messages.fetch()
			messages
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
		closeChannel: ->
			swipy.slackSync.apiRequest(@getApiType() + ".close",{channel: @id}, 
				(res, error) =>
					console.log("closed channel", res, error)
			)
		fetchOlderMessages: (callback) ->
			collection = @getMessageCollection()
			firstObject = collection.at(0)
			@fetchMessages(firstObject.get("ts"), callback)
		fetchMessages: (newest, callback) ->
			options = {channel: @id, count: @skipCount }
			collection = @getMessageCollection()
			if newest
				options.latest = newest
				allowMore = true
				options.inclusive = 1
			swipy.slackSync.apiRequest(@getApiType() + ".history",options, 
				(res, error) =>
					if res and res.ok
						@hasFetched = true
						for message in res.messages
							@addMessage(message, false, allowMore)
					callback?(res,error)
			)
		addMessage: (message, increment, allowMore) ->
			collection = @getMessageCollection()
			identifier = message.ts
			identifier = message.deleted_ts if message.deleted_ts?
			identifier = message.message.ts if message.message? and message.message.ts?
			model = collection.get(identifier)
			if !model
				if increment and message.user isnt swipy.slackCollections.users.me().id
					@save("unread_count_display", @get("unread_count_display")+1)
					if @get("is_im") and @getName() is "slackbot"
						swipy.sync.shortBouncedSync()
						console.log "bounced sync from sofi"
					if @get("is_im") and (!swipy.isWindowOpened or @getName() isnt swipy.activeId)
						if swipy.bridge.bridge # OR you were mentioned in the task /TODO:
							text = "You received 1 new message"
							text = message.text if message.text
							title = "[Swipes] " + @getName() 
							swipy.bridge.callHandler("notify",{title: title, message: text})
						else if window.process? and process.versions['electron'] 
							nodeRequire('ipc').send('newEvent', 'data');
						else
							Backbone.trigger("play-new-message")
				return if(!@hasFetched? or !@hasFetched)
				message.channelId = @id
				newMessage = collection.create( message )
				if collection.length > @skipCount and !allowMore
					first = collection.shift()
					first.localStorage = collection.localStorage
					first.destroy()
			else
				if(message.deleted_ts)
					collection.remove(model)
				else
					if message.message
						model.save(message.message)
					else
						model.save(message)
		markAsRead: ->
			collection = @getMessageCollection()
			options = {channel: @id }
			return if !collection.models.length
			lastModel = collection.at(collection.models.length-1)
			options.ts = lastModel.get("ts")
			unixLastModel = new Date(parseFloat(lastModel.get("ts"))*1000).getTime()
			if @get("last_read")
				unixLastRead = new Date(parseFloat(@get("last_read"))*1000).getTime()
				return if unixLastModel <= unixLastRead
			swipy.slackSync.apiRequest(@getApiType() + ".mark",options, 
				(res, error) =>
					if res and res.ok
						console.log "marked"
					else
						console.log error
			)