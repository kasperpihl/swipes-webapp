define [
	"underscore"
	"js/view/list/ActionBar"
	"js/view/list/DesktopTask"
	"js/view/list/TouchTask"
	"text!templates/todo-list.html"
	"mousetrapGlobal"
	], (_, ActionBar, DesktopTaskView, TouchTaskView, ToDoListTmpl) ->
	Parse.View.extend
		initialize: ->
			# This deferred is resolved after view has been transitioned in
			@transitionDeferred = new $.Deferred()

			# Set HTML tempalte for our list
			@template = _.template ToDoListTmpl

			# Store subviews in this array so we can kill them (and free up memory) when we no longer need them
			@subviews = []

			# Render the list whenever it updates, 5ms is just enough to work around mutiple events firing frequently
			@renderList = _.debounce( @renderList, 5 )
			@listenTo( swipy.todos, "add remove reset change:priority change:completionDate change:schedule change:rejectedByTag change:rejectedBySearch", @renderList )

			# Handle task actions
			@listenTo( Backbone, "complete-task", @completeTasks )
			@listenTo( Backbone, "todo-task", @markTaskAsTodo )
			@listenTo( Backbone, "schedule-task", @scheduleTasks )
			@listenTo( Backbone, "schedule-task", @scheduleTasks )
			@listenTo( Backbone, "scheduler-cancelled", @handleSchedulerCancelled )

			# Re-render list once per minute, activating any scheduled tasks.
			@listenTo( Backbone, "clockwork/update", @moveTasksToActive )

			Mousetrap.bindGlobal( "mod+a", $.proxy( @selectAllTasks, @ ) )

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
		selectAllTasks: (e) ->
			# Prevent default (select all text on page || select all text in input), unless input is focused AND have text input.
			taskInput = swipy.input.view.$el.find "input"
			unless taskInput.val() and taskInput.is ":focus"
				e.preventDefault()
				tasks = @getTasks()
				doSelect = _.any tasks, (task) -> not task.get("selected")
				_.invoke( tasks, "set", "selected", doSelect )
		moveTasksToActive: ->
			now = new Date().getTime()
			# Get all tasks that are scheduled within the current 1001ms
			# (Includes stuff moved from completed, which is defaulting to 1000ms in the past)
			movedFromScheduled = _.filter @getTasks(), (m) ->
				return false unless m.has "schedule"
				return now - m.get( "schedule" ).getTime() < 1001

			# If we have tasks then bump all tasks +1 and
			# set order: 0 and animateIn: yes for all of them
			if movedFromScheduled.length

				# If we only moved 1 item, and it's order was already 0, no need to bump
				if movedFromScheduled.length is 1 and movedFromScheduled[0].get("order") is 0
					# ... Do nothing — This is only the case when we have multiple instances of
					# a list at the same time. Like in our testing environment.
					movedFromScheduled[0].set( "animateIn", yes )
				else
					swipy.todos.bumpOrder( "down", 0, movedFromScheduled.length )
					_.invoke( movedFromScheduled, "set", { order: 0, animateIn: yes } )

				# After changes, re-render the list
				@renderList()
		renderList: ->
			# Remove any old HTML before appending new stuff.
			@$el.empty()
			@killSubViews()

			todos = @getTasks()

			# Rejects models filtered out by tag or search
			todos = _.reject( todos, (m) -> m.get( "rejectedByTag" ) or m.get "rejectedBySearch" )

			# Deselect any selected items
			_.invoke( todos, "set", { selected: no } )

			@beforeRenderList todos

			for group in @groupTasks todos
				tasksJSON = _.invoke( group.tasks, "toJSON" )
				$html = $( @template { title: group.deadline, tasks: tasksJSON } )
				list = $html.find "ol"
				for model in group.tasks
					if model.get "tags" then console.log model.get "tags"
					view = if Modernizr.touch then new TouchTaskView( { model } ) else new DesktopTaskView( { model } )
					@subviews.push view
					list.append view.el

				@$el.append $html

			@afterRenderList todos

		beforeRenderList: (todos) ->
		afterRenderList: (todos) ->

		getViewForModel: (model) ->
			return view for view in @subviews when view.model.cid is model.cid
		completeTasks: (tasks) ->
			minOrder = Math.min _.invoke( tasks, "get", "order" )...

			# Bump order for tasks
			swipy.todos.bumpOrder( "up", minOrder, tasks.length )

			for task in tasks
				view = @getViewForModel task

				# Wrap in do, so reference to model isn't changed next time the loop iterates
				if view? then do =>
					m = task
					view.swipeRight( "completed" ).then =>
						m.completeTask()

			swipy.analytics.tagEvent( "Completed Tasks", { "Number of Tasks": tasks.length } )

		markTaskAsTodo: (tasks) ->
			for task in tasks
				view = @getViewForModel task

				# Wrap in do, so reference to model isn't changed next time the loop iterates
				if view? then do ->
					m = task
					view.swipeRight("todo").then ->
						m.scheduleTask m.getDefaultSchedule()

		scheduleTasks: (tasks) ->
			deferredArr = []

			for task in tasks
				view = @getViewForModel task

				# Wrap in do, so reference to model isn't changed next time the loop iterates
				if view? then do ->
					m = task
					deferredArr.push view.swipeLeft("scheduled", no)

			$.when( deferredArr... ).then -> Backbone.trigger( "show-scheduler", tasks )

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
