define ['view/default-view'], (DefaultView) ->
	DefaultView.extend
		init: ->
			# Set HTML tempalte for our list
			@listTmpl = _.template $('#template-list').html()

			# Render the list whenever it updates
			swipy.collection.on 'change', @renderList, @
		render: ->
			@renderList()
		renderList: ->
			itemsJSON = new Backbone.Collection( swipy.collection.getActive() ).toJSON()
			@$el.find('.list-wrap').html @listTmpl( { items: itemsJSON } )
		customCleanUp: ->
			# Unbind all events
			swipy.collection.off()