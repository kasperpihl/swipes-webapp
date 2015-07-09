define [ "underscore", "js/model/sync/ProjectModel", "localStorage"], ( _, ProjectModel) ->
	Backbone.Collection.extend
		model: ProjectModel
		localStorage: new Backbone.LocalStorage("ProjectCollection")
		initialize: ->
		destroy: ->