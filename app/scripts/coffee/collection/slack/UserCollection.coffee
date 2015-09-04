define [ "underscore", "js/model/slack/UserModel", "localStorage"], ( _, UserModel) ->
	Backbone.Collection.extend
		model: UserModel
		localStorage: new Backbone.LocalStorage("UserCollection")
		slackbot: ->
			@findWhere({name: "slackbot"})
		me: ->
			@findWhere({me: true})