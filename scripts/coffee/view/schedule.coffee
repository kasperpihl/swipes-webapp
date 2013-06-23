define ['view/list-view'], (ListView) ->
	ListView.extend
		el: "#schedule"
		renderList: ->
			items = new Backbone.Collection( swipy.collection.getScheduled() )
			@$el.find('.list-wrap').html @listTmpl( { items: items.toJSON() } )
			@afterRenderList items