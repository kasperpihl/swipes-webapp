define [ "underscore", "js/model/slack/BotModel", "localStorage"], ( _, BotModel) ->
	Backbone.Collection.extend
		model: BotModel
		localStorage: new Backbone.LocalStorage("BotCollection")