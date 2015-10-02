define [ "underscore", "js/model/slack/UserModel", "localStorage"], ( _, UserModel) ->
	Backbone.Collection.extend
		model: UserModel
		localStorage: new Backbone.LocalStorage("UserCollection")
		activeUsers: ->
			@filter((user) =>
				return false if user.get("deleted")
				return false if user.id is "USLACKBOT"
				return true
			)
		slackbot: ->
			@findWhere({name: "slackbot"})
		me: ->
			@findWhere({me: true})