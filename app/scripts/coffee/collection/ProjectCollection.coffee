define [ "underscore", "localStorage"], ( _) ->
	Backbone.Collection.extend
		localStorage: new Backbone.LocalStorage("ProjectCollection")
		initialize: ->
		destroy: ->