define ["underscore", "js/collection/slack/MessageCollection"], (_, MessageCollection) ->
	Backbone.Model.extend
		className: "Channel"
		excludeFromJSON: [ "messages" ]
		initialize: ->
			messageCollection = new MessageCollection()
			messageCollection.localStorage = new Backbone.LocalStorage("MessageCollection-" + @id )
			messageCollection.fetch()
			@set("messages", messageCollection)
		getApiType: ->
			apiType = "channels"
			if @id.startsWith("D")
				apiType = "im"
			if @id.startsWith("G")
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
		addMessage: (message) ->
			return if(!@hasFetched? or !@hasFetched)
			collection = @get("messages")
			if !collection.get(message.ts)
				collection.create( message )
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