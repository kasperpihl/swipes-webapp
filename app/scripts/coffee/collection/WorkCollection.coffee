define [ "underscore", "js/model/WorkModel", "localStorage"], ( _, WorkModel) ->
	Backbone.Collection.extend
		model: WorkModel
		localStorage: new Backbone.LocalStorage("WorkCollection")
		initialize: ->
		destroy: ->