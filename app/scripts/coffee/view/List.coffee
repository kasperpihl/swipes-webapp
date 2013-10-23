define [
	"underscore"
	"view/list/ActionBar"
	"text!templates/todo-list.html"
	], (_, ActionBar, ToDoListTmpl) ->
	Backbone.View.extend
		initialize: ->
			# This deferred is resolved after view has been transitioned in
			@transitionDeferred = new $.Deferred()

			# Set HTML tempalte for our list
			@template = _.template ToDoListTmpl

			# Store subviews in this array so we can kill them (and free up memory) when we no longer need them
			@subviews = []

			# Render the list whenever it updates
			@renderList = _.debounce( @renderList, 300 )
			@listenTo( swipy.todos, "add remove reset change:completionDate change:schedule change:rejectedByTag change:rejectedBySearch", @renderList )

			# Handle task actions
			@listenTo( Backbone, "complete-task", @completeTasks )
			@listenTo( Backbone, "todo-task", @markTaskAsTodo )
			@listenTo( Backbone, "schedule-task", @scheduleTasks )
			@listenTo( Backbone, "schedule-task", @scheduleTasks )
			@listenTo( Backbone, "scheduler-cancelled", @handleSchedulerCancelled )

			@render()
		render: ->
			@renderList()
			$("#add-task input").focus()
			return @
		sortTasks: (tasks) ->
			return _.sortBy tasks, (model) -> model.get( "schedule" )?.getTime()
		groupTasks: (tasksArr) ->
			tasksArr = @sortTasks tasksArr
			tasksByDate = _.groupBy( tasksArr, (m) -> m.get "scheduleStr" )
			return ( { deadline, tasks } for deadline, tasks of tasksByDate )
		getTasks: ->
			# Fetch todos that are active
			return swipy.todos.getActive()

		loadTaskView: ->
			dfd = new $.Deferred()

			if Modernizr.touch then require ["view/list/DesktopTask"], (TaskView) -> dfd.resolve TaskView
			else require ["view/list/TouchTask"], (TaskView) -> dfd.resolve TaskView

			return dfd.promise()
		renderList: ->
			@loadTaskView.done (TaskView) =>
				# Remove any old HTML before appending new stuff.
				@$el.empty()
				@killSubViews()

				todos = @getTasks()

				# Rejects models filtered out by tag or search
				todos = _.reject todos, (m) ->
					# console.log "Is #{ m.get 'title' } rejected by tags? ", m.get "rejectedByTag"
					m.get( "rejectedByTag" ) or m.get( "rejectedBySearch" )

				# Deselect any selected items
				_.invoke( todos, "set", { selected: no } )

				@beforeRenderList todos

				for group in @groupTasks todos
					tasksJSON = _.invoke( group.tasks, "toJSON" )
					$html = $( @template { title: group.deadline, tasks: tasksJSON } )
					list = $html.find "ol"

					for model in group.tasks
						view = new TaskView( { model } )
						@subviews.push view
						list.append view.el

					@$el.append $html

				@afterRenderList todos

		beforeRenderList: (todos) ->
		afterRenderList: (todos) ->

		getViewForModel: (model) ->
			return view for view in @subviews when view.model.cid is model.cid
		completeTasks: (tasks) ->
			for task in tasks
				view = @getViewForModel task

				# Wrap in do, so reference to model isn't changed next time the loop iterates
				if view? then do ->
					m = task
					view.swipeLeft("completed").then -> m.set { completionDate: new Date(), schedule: null }

		markTaskAsTodo: (tasks) ->
			for task in tasks
				view = @getViewForModel task

				# Wrap in do, so reference to model isn't changed next time the loop iterates
				if view? then do ->
					m = task
					view.swipeLeft("todo").then ->
						oneSecondAgo = new Date()
						oneSecondAgo.setSeconds oneSecondAgo.getSeconds() - 1
						m.set { completionDate: null, schedule: oneSecondAgo }

		scheduleTasks: (tasks) ->
			deferredArr = []

			for task in tasks
				view = @getViewForModel task

				# Wrap in do, so reference to model isn't changed next time the loop iterates
				if view? then do ->
					m = task
					deferredArr.push view.swipeRight("scheduled", no)

			$.when( deferredArr... ).then => Backbone.trigger( "show-scheduler", tasks )

		handleSchedulerCancelled: (tasks) ->
			for task in tasks
				view = @getViewForModel task
				if view? then view.reset()

		transitionInComplete: ->
			@actionbar = new ActionBar()
			@transitionDeferred.resolve()
		killSubViews: ->
			view.remove() for view in @subviews
			@subviews = []
		customCleanUp: ->
			# Extend this in subviews
			#
		remove: ->
			@cleanUp()
			@$el.empty()
		cleanUp: ->
			# A hook for the subviews to do custom clean ups
			@customCleanUp()

			# Reset transitionDeferred
			@transitionDeferred = null

			# Unbind all events
			@stopListening()
			@undelegateEvents()

			# Deactivate actionbar (Do this before killing subviews)
			@actionbar?.kill()

			# Deselect all todos, so selection isnt messed up in new view
			swipy.todos.invoke( "set", { selected: no } )

			# Run clean-up routine on sub views
			@killSubViews()
