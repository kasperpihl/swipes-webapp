define ["underscore", "js/collection/slack/MessageCollection"], (_, MessageCollection) ->
	Backbone.Model.extend
		className: "Channel"
		excludeFromJSON: [ "messages" ]
		initialize: ->
			messageCollection = new MessageCollection()
			messageCollection.localStorage = new Backbone.LocalStorage("MessageCollection-" + @id )
			messageCollection.fetch()
			@set("messages", messageCollection)
		fetchMessages: (collection) ->
			options = {channel: @id, count: 50 }
			apiType = "channels"
			if @id.startsWith("D")
				apiType = "im"
			collection = @get("messages")
			collection.fetch()
			if collection.models.length
				lastModel = collection.at(collection.models.length-1)
				options.oldest = lastModel.get("ts")
			swipy.slackSync.apiRequest(apiType + ".history",options, 
				(res, error) =>
					if res and res.ok
						for message in res.messages
							if !collection.get(message.ts)
								collection.create( message )
			)
		addMessage: (message) ->
			collection = @get("messages")
			if !collection.get(message.ts)
				collection.create( message )