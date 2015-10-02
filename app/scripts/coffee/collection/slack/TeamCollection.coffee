define [ "underscore", "js/model/slack/TeamModel", "localStorage"], ( _, TeamModel) ->
	Backbone.Collection.extend
		model: TeamModel
		localStorage: new Backbone.LocalStorage("TeamCollection")