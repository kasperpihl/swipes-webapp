define [ "underscore", "js/model/slack/UserModel", "localStorage"], ( _, UserModel) ->
	Backbone.Collection.extend
		model: UserModel
		localStorage: new Backbone.LocalStorage("UserCollection")
		me: ->
			@findWhere({me: true})