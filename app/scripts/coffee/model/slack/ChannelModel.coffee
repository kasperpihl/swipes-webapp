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
			collection = @get("messages")
			collection.fetch()
			if collection.models.length
				lastModel = collection.at(collection.models.length-1)
				options.oldest = lastModel.get("ts")
			swipy.slackSync.apiRequest(@collection.slackApiType+".history",options, 
				(res, error) =>
					if res and res.ok
						for message in res.messages
							collection.create( message )
			)