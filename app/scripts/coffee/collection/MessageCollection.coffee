define [ "underscore", "js/model/sync/MessageModel", "localStorage"], ( _, MessageModel) ->
	Backbone.Collection.extend
		model: MessageModel
		localStorage: new Backbone.LocalStorage("MessageCollection")
		initialize: ->
		destroy: ->