define ['view/list-view'], (ListView) ->
	ListView.extend
		el: "#schedule"
		renderList: ->
			itemsJSON = new Backbone.Collection( swipy.collection.getScheduled() ).toJSON()
			@$el.find('.list-wrap').html @listTmpl( { items: itemsJSON } )