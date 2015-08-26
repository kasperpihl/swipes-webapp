define [
	"underscore"
	"backbone"
	"js/collection/slack/UserCollection"
	"js/collection/slack/BotCollection"
	"js/collection/slack/ChannelCollection"
	"js/collection/slack/MessageCollection"
	"collectionSubset"
	], (_, Backbone, UserCollection, BotCollection, ChannelCollection, MessageCollection) ->
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