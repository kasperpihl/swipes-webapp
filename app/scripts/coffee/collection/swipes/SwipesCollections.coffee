define [
	"underscore"
	"backbone"
	"js/collection/swipes/UserCollection"
	"js/collection/swipes/TeamCollection"
	"js/collection/swipes/AppCollection"
	"js/collection/swipes/ChannelCollection"
	"collectionSubset"
	], (_, Backbone, UserCollection, TeamCollection, AppCollection, ChannelCollection) ->
	class Collections
		constructor: ->
			
			@users = new UserCollection()
			@teams = new TeamCollection()
			@apps = new AppCollection()
			@channels = new ChannelCollection()
			@channels.localStorage = new Backbone.LocalStorage("ChannelCollection")

			@all = [@teams, @users, @apps, @channels]
		fetchAll: ->
			for collection in @all
				collection.fetch()