define ["view/list-view"], (ListView) ->
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

			# Unless touch, load out keyboard shortcut plugin and bind to cmd+n for add new
			unless Modernizr.touch then require ["plugins/jwerty/jwerty"], => jwerty.key "cmd+s", @addNew
		addNew: ->
			todo = prompt "Todo title:"
			if todo then console.log swipy.collection.add( title: todo )