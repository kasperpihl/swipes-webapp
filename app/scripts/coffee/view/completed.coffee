define ["view/List"], (ListView) ->
	ListView.extend
		renderList: ->
			# console.warn "Rendering completed todo list"
			# items = new Backbone.Collection( swipy.collection.getCompleted() )
			# @$el.find('.list-wrap').html @listTmpl( { items: items.toJSON() } )
			# @afterRenderList items