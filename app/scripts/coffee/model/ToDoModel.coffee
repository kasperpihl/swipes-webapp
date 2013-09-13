define ['backbone'], (Backbone) ->
	Backbone.Model.extend
		defaults: 
			title: ""
			order: 0
			schedule: null
			completionDate: null
			repeatOption: "never"
			repeatDate: null
			repeatCount: 0
			tags: null
			notes: ""
			deleted: no