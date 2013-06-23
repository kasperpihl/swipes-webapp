define ['view/list-view'], (ListView) ->
	ListView.extend
		el: "#completed"
		renderList: ->
			itemsJSON = new Backbone.Collection( swipy.collection.getCompleted() ).toJSON()
			@$el.find('.list-wrap').html @listTmpl( { items: itemsJSON } )