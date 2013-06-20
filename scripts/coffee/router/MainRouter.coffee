define ['backbone'], (Backbone) ->
	MainRouter = Backbone.Router.extend
		routes:
			':term': 'goto'
			'': 'goto'
		goto: (route = 'todo') -> 
			$(document).trigger('navigate/page', [route]);

	return MainRouter