define [ "underscore", "js/model/ProjectModel", "localStorage"], ( _, ProjectModel) ->
	Backbone.Collection.extend
		model: ProjectModel
		localStorage: new Backbone.LocalStorage("ProjectCollection")
		initialize: ->
		destroy: ->