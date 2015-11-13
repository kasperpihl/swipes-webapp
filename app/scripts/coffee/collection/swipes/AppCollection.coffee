define [ "underscore", "js/model/swipes/AppModel", "localStorage"], ( _, AppModel) ->
	Backbone.Collection.extend
		model: AppModel
		localStorage: new Backbone.LocalStorage("AppCollection")