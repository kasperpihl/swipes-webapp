define [ "underscore", "js/model/swipes/ChannelModel", "localStorage"], ( _, ChannelModel) ->
	Backbone.Collection.extend
		model: ChannelModel
		slackApiType: "channels"
		localStorage: new Backbone.LocalStorage("ChannelCollection")
		slackbot: ->
			@findWhere({user: "USLACKBOT"})
		activeChannels: ->
			filteredChannels = _.filter(@models, (channel) ->
				if channel.get("is_channel") and !channel.get("is_archived")
					return true
				return false
			)

			return filteredChannels