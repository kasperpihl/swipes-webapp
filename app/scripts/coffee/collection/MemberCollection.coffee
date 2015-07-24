define [ "underscore", "js/model/sync/MemberModel", "localStorage"], ( _, MemberModel) ->
	Backbone.Collection.extend
		model: MemberModel
		localStorage: new Backbone.LocalStorage("MemberCollection")
		getMe: ->
			@findWhere({"me":true})
		initialize: ->
		destroy: ->