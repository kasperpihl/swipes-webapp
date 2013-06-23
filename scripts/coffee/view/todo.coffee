define ['view/default-view'], (DefaultView) ->
	DefaultView.extend
		el: "#todo"
		events: 
			'tap .add-new': 'addNew'
			'click .add-new': 'addNew'
		init: ->
			# Set HTML tempalte for our list
			@listTmpl = _.template $('#template-list').html()

			# Render the list whenever it updates
			swipy.collection.on 'add remove reset', @renderList, @
		addNew: ->
			todo = prompt "Todo title:"
			if todo then log swipy.collection.add( title: todo )
		render: ->
			@renderList()
		renderList: ->
			itemsJSON = new Backbone.Collection( swipy.collection.getActive() ).toJSON()
			@$el.find('.list-wrap').html @listTmpl( { items: itemsJSON } )
		customCleanUp: ->
			# Unbind all events
			swipy.collection.off()