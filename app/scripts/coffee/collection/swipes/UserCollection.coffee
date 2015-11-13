define [ "underscore", "js/model/swipes/UserModel", "localStorage"], ( _, UserModel) ->
	Backbone.Collection.extend
		model: UserModel
		localStorage: new Backbone.LocalStorage("UserCollection")
		activeUsers: (includeSlackbot)->
			@filter((user) =>
				return false if user.get("deleted")
				return false if !includeSlackbot? and !includeSlackbot and user.id is "USLACKBOT"
				return true
			)
		slackbot: ->
			@findWhere({name: "slackbot"})
		me: ->
			@findWhere({me: true})