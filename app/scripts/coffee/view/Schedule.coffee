define ['view/List'], (ListView) ->
	ListView.extend
		renderList: ->
			# items = new Backbone.Collection( swipy.collection.getScheduled() )
			# @$el.find('.list-wrap').html @listTmpl( { items: items.toJSON() } )
			# @afterRenderList items