define ['view/list-view'], (ListView) ->
	ListView.extend
		el: "#completed"
		renderList: ->
			items = new Backbone.Collection( swipy.collection.getCompleted() )
			@$el.find('.list-wrap').html @listTmpl( { items: items.toJSON() } )
			@afterRenderList items