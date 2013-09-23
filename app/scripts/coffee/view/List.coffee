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
			return _.sortBy tasks, (model) -> model.get( "schedule" ).getTime()
		groupTasks: (tasksArr) ->
			tasksArr = @sortTasks tasksArr
			tasksByDate = _.groupBy( tasksArr, (m) -> m.get "scheduleStr" )
			return ( { deadline, tasks } for deadline, tasks of tasksByDate )
		getTasks: ->
			# Fetch todos that are active
			return swipy.todos.getActive()
		renderList: ->
			type = if Modernizr.touch then "Touch" else "Desktop"

			# For now, force type to be desktop
			type = "Desktop"
			
			require ["view/list/#{type}Task"], (TaskView) =>
				# Remove any old HTML before appending new stuff.
				@$el.empty()
				@killSubViews()

				todos = @getTasks()

				for group in @groupTasks todos
					tasksJSON = _.invoke( group.tasks, "toJSON" )
					$html = $( @template( { title: group.deadline, tasks: tasksJSON } ) )
					list = $html.find "ol"
					
					for model in group.tasks
						view = new TaskView( { model } )
						@subviews.push view
						list.append view.el

					@$el.append $html

				@afterRenderList todos

		afterRenderList: (todos) ->
			# Hook for other views
		killSubViews: ->
			view.remove() for view in @subviews
			@subviews = []
		customCleanUp: ->
			# Unbind all events
			swipy.todos.off()
			@killSubViews()
