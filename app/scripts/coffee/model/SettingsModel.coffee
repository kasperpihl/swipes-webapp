define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.Model.extend
		url: "test"
		defaults: 
			snoozes: [1,2,3]
			hasPlus: no