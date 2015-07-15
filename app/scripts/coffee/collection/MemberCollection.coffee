define [ "underscore", "js/model/sync/MemberModel", "localStorage"], ( _, MemberModel) ->
	Backbone.Collection.extend
		model: MemberModel
		localStorage: new Backbone.LocalStorage("MemberCollection")
		initialize: ->
		destroy: ->