define ['view/default-view', 'view/listitem-view'], (DefaultView, ListItemView) ->
	DefaultView.extend
		init: ->
			# Set HTML tempalte for our list
			@listTmpl = _.template $("#template-list").html()

			# Render the list whenever it updates
			swipy.collection.on "change", @renderList, @
		render: ->
			@renderList()
		renderList: ->
			items = new Backbone.Collection( swipy.collection.getActive() )
			@$el.find('.list-wrap').html( @listTmpl( { items: items.toJSON() } ) )
			@afterRenderList items
		afterRenderList: (models) ->
			@$el.find('ol.todo > li').each (i, el) =>
				new ListItemView el: el, model: models.at(i)
		customCleanUp: ->
			# Unbind all events
			swipy.collection.off()
