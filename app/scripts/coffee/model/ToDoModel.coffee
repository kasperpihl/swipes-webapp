define ['backbone'], (Backbone) ->
	Backbone.Model.extend
		defaults: 
			state: 'todo'
			title: ''
			alert: null
			tags: null
