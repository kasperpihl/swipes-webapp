define [ "underscore", "js/model/slack/ChannelModel", "localStorage"], ( _, ChannelModel) ->
	Backbone.Collection.extend
		model: ChannelModel
		slackApiType: "channels"
		localStorage: new Backbone.LocalStorage("ChannelCollection")
		slackbot: ->
			@findWhere({user: "USLACKBOT"})