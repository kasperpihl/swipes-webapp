define [
	"underscore"
	"backbone"
	"js/collection/slack/UserCollection"
	"js/collection/slack/BotCollection"
	"js/collection/slack/ChannelCollection"
	"collectionSubset"
	], (_, Backbone, UserCollection, BotCollection, ChannelCollection) ->
	class Collections
		constructor: ->
			
			@users = new UserCollection()
			@bots = new BotCollection()

			@channels = new ChannelCollection()
			@channels.localStorage = new Backbone.LocalStorage("ChannelCollection")

			@all = [@users, @bots, @channels]
		fetchAll: ->
			for collection in @all
				collection.fetch()