define [
	"underscore"
	"js/collection/slack/UserCollection"
	"js/collection/slack/BotCollection"
	"js/collection/slack/ChannelCollection"
	"js/collection/slack/MessageCollection"
	"plugins/backbone.collectionsubset"
	], (_, UserCollection, BotCollection, ChannelCollection, MessageCollection) ->
	class Collections
		constructor: ->
			
			@users = new UserCollection()
			@bots = new BotCollection()

			@channels = new ChannelCollection()
			@channels.localStorage = new Backbone.LocalStorage("ChannelCollection")

			@messages = new MessageCollection()

			@all = [@users, @bots, @channels]
		fetchAll: ->
			for collection in @all
				collection.fetch()