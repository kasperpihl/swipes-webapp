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

			@ims = new ChannelCollection()
			@ims.slackApiType = "im"
			@ims.localStorage = new Backbone.LocalStorage("ImCollection")

			@groups = new ChannelCollection()
			@groups.slackApiType = "groups"
			@groups.localStorage = new Backbone.LocalStorage("GroupCollection")

			@messages = new MessageCollection()

			@all = [@users, @bots, @channels, @ims, @groups]
		fetchAll: ->
			for collection in @all
				collection.fetch()