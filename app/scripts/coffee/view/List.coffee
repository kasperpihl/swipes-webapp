define ["underscore", "view/Default", "text!templates/todo-list.html"], (_, DefaultView, ToDoListTmpl) ->
	DefaultView.extend
		events:
			if Modernizr.touch then "tap" else "click "
		init: ->
			# Set HTML tempalte for our list
			@template = _.template ToDoListTmpl

			# Store subviews in this array so we can kill them (and free up memory) when we no longer need them
			@subviews = []

			# Render the list whenever it updates
			swipy.todos.on( "add remove reset", @renderList, @ )
		render: ->
			@renderList()
			return @
		sortTasks: (tasks) ->
			return tasks
		groupTasks: (tasksArr) ->
			tasksArr = @sortTasks tasksArr
			tasksByDate = _.groupBy( tasksArr, (m) -> m.get "scheduleString" )
			return ( { deadline, tasks } for deadline, tasks of tasksByDate )
		getListItems: ->
			# Fetch todos that are active
			return swipy.todos.getActive()
		renderList: ->
			type = if Modernizr.touch then "Touch" else "Desktop"
			
			require ["view/list/#{type}ListItem"], (ListItemView) =>
				# Remove any old HTML before appending new stuff.
				@$el.empty()
				todos = @getListItems()

				for group in @groupTasks todos
					tasksJSON = _.invoke( group.tasks, "toJSON" )
					$html = $( @template( { title: group.deadline, tasks: tasksJSON } ) )
					list = $html.find "ol"
					
					for model in group.tasks
						list.append new ListItemView( { model } ).el

					@$el.append $html

				@afterRenderList todos

		afterRenderList: (collection) ->
			# Hook for other views
		customCleanUp: ->
			# Unbind all events
			swipy.todos.off()
			
			view.remove() for view in @subviews
