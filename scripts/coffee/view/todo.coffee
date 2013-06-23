define ['view/list-view'], (ListView) ->
	ListView.extend
		el: "#todo"
		events: 
			'tap .add-new': 'addNew'
			'click .add-new': 'addNew'
		init: ->
			# Set HTML tempalte for our list
			@listTmpl = _.template $('#template-list').html()

			# Render the list whenever it updates
			swipy.collection.on 'add remove reset change', @renderList, @
		addNew: ->
			todo = prompt "Todo title:"
			if todo then log swipy.collection.add( title: todo )