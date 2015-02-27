define [
	"underscore"
	"js/view/list/ActionBar"
	"js/view/list/DesktopTask"
	"js/view/list/TouchTask"
	"text!templates/todo-list.html"
	"mousetrapGlobal"
	"gsap-scroll" 
	"gsap"
	], (_, ActionBar, DesktopTaskView, TouchTaskView, ToDoListTmpl) ->
	Backbone.View.extend
		initialize: ->
			@longPressThreshold = 2
			@currentLongPressCount = 0
			@didHitALongPress = false
			# This deferred is resolved after view has been transitioned in
			@transitionDeferred = new $.Deferred()

			# Set HTML tempalte for our list
			@template = _.template ToDoListTmpl

			# Store subviews in this array so we can kill them (and free up memory) when we no longer need them
			@subviews = []

			# Render the list whenever it updates, 5ms is just enough to work around mutiple events firing frequently
			@renderList = _.debounce( @renderList, 5 )
			@longBounceRenderList = _.debounce( @renderList, 500 )
			@listenTo( Backbone, "opened-window", @clearForOpening )

			@listenTo( swipy.todos, "add remove reset change:priority change:completionDate change:schedule change:rejectedByTag change:rejectedBySearch", @renderList )
			#@listenTo( swipy.todos, "change:order", @changedOrder )

			# Handle task actions
			@listenTo( Backbone, "complete-task", @completeTasks )
			@listenTo( Backbone, "todo-task", @markTasksAsTodo )
			@listenTo( Backbone, "schedule-task", @scheduleTasks )
			@listenTo( Backbone, "scheduler-cancelled", @handleSchedulerCancelled )

			@listenTo( Backbone, "did-press-task", @handleDidPressTask )
			@listenTo( Backbone, "pick-schedule-option", @snoozedATask )
			# Re-render list once per minute, activating any scheduled tasks.
			@listenTo( Backbone, "clockwork/update", @moveTasksToActive )

			Mousetrap.bindGlobal( "mod+a", $.proxy( @selectAllTasks, @ ) )
			_.bindAll( @, "keyDownHandling", "keyUpHandling", "selectTasksForTasksWithShift", "clearForOpening", "longPressHandling", "snoozedATask", "changedOrder" )
			@setLastIndex( -1, true )
			@shouldResetLast = false
			@render()
		changedOrder: ->
			@longBounceRenderList()
		snoozedATask: ->
			@afterMovedItems()
		clearForOpening: ->
			@holdModifier = null
			#@clearLongPress()
		setLastIndex: (index, saveToShift) ->
			@lastSelectedIndex = index
			if saveToShift
				@currentToStartFromInShift = index
		longPressHandling: (e) ->
			@currentLongPressCount = 0
			@didHitALongPress = true
			@actionForDirection( e, true )
		actionForDirection: ( e , longSwipe ) ->
			if e.keyCode is 37 or e.keyCode is 39
				if e.keyCode is 37
					left = true
			else return
			type = null
			type = "todo" if @$el.hasClass("todo")
			type = "completed" if @$el.hasClass("completed")
			type = "scheduled" if @$el.hasClass("scheduled")
			return if !type?
			if left?
				if type is "todo" or type is "scheduled" or type is "completed" and longSwipe
					@scheduleTasks(null, true)
				else if type is "completed" and !longSwipe
					@markTasksAsTodo(null, true)
			else
				if type is "todo" or type is "scheduled" and longSwipe
					@completeTasks(null, true)
				else if type is "scheduled" and !longSwipe
					@markTasksAsTodo(null, true)
				
		keyDownHandling: (e) ->
			return if $("input").is(":focus")

			if e.keyCode is 32
				e.preventDefault()
			# shift key

			if e.keyCode is 16
				if !@holdModifier?
					@holdModifier = "shift";
					if !@currentToStartFromInShift? or @currentToStartFromInShift is -1
						@setLastIndex( 0, true )
					else 
						@setLastIndex(@currentToStartFromInShift, true )
			# cmd / ctrl
			if e.keyCode is 91 or e.keyCode is 17
				if !@holdModifier?
					@holdModifier = "cmd";
			# left arrow / right arrow
			if e.keyCode is 37 or e.keyCode is 39
				if !@currentLongPressKey?
					@currentLongPressKey = e.keyCode
				if e.keyCode is @currentLongPressKey and !@didHitALongPress
					@currentLongPressCount++
					if @currentLongPressCount > @longPressThreshold
						@longPressHandling(e)

			# arrow up and arrow down
			if e.keyCode is 40 or e.keyCode is 38
				e.preventDefault()
				numberOfTasks = @subviews.length
				if e.keyCode is 40
					index = @lastSelectedIndex + 1
				else if e.keyCode is 38
					index = @lastSelectedIndex - 1
				index = 0 if index < 0
				index = numberOfTasks - 1 if index >= numberOfTasks

				foundView = view for view, i in @subviews when index is i
				if foundView?
					task = foundView.model
					task.set( "selected", true )
					saveToShift = @holdModifier isnt "shift"
					@setLastIndex( index, saveToShift )
					@selectedModels([task])
					
					# Handle auto scroll
					scrollableView = $("#scrollcont")
					mainContentView = $('#main-content')

					contentY = mainContentView.position().top
					itemY = foundView.$el.position().top
					sectionY = foundView.$el.closest(".task-header").position().top
					totalItemY = contentY+sectionY+itemY
					itemHeight = foundView.$el.height()
					height = scrollableView.height()
					totalContentHeight = mainContentView.height() + mainContentView.offset().top
					padding = 150
					currentScroll = scrollableView.scrollTop()

					doScroll = true
					if totalItemY < (currentScroll + padding + itemHeight )
						targetY = totalItemY - padding - itemHeight
					else if totalItemY > (currentScroll + height - padding)
						targetY = totalItemY - height + padding
					else doScroll = false
					if targetY <= contentY
						targetY = 0
					if doScroll
						TweenLite.to( scrollableView, 0.05, { scrollTo: targetY } )
		clearLongPress: ->
			@didHitALongPress = false
			@currentLongPressKey = null
			@currentLongPressCount = 0
		keyUpHandling: (e) ->
			return if $("input").is(":focus")
			#console.log e.keyCode
			if e.keyCode is 27
				@deselectAllTasksButTasks([])
				
			if e.keyCode is 32
				swipy.router.navigate("add",true )
			if e.keyCode is 13
				@openSelectedTask()
			if e.keyCode is 49 and @state isnt "schedule"
				swipy.router.navigate("list/scheduled",true)
			if e.keyCode is 50 and @state isnt "tasks"
				swipy.router.navigate("list/todo",true )
			if e.keyCode is 51 and @state isnt "done"
				swipy.router.navigate("list/completed",true )

			# shift / ctrl / cmd
			if e.keyCode is 16 or e.keyCode is 17 or e.keyCode is 91
				@holdModifier = null
			# shift
			###if e.keyCode is 16
				@currentToStartFromInShift = null###
			# left arrow / right arrow
			if e.keyCode is 37 or e.keyCode is 39
				if @currentLongPressKey?
					if @currentLongPressKey is e.keyCode
						if !@didHitALongPress
							@actionForDirection(e, false)
						@clearLongPress()
			
					
		openSelectedTask: ->
			lastTask = view.model for view, i in @subviews when i is @lastSelectedIndex
			if lastTask and swipy.todos.getSelected().length > 0
				swipy.router.navigate( "edit/#{ lastTask.id }", yes ) 
		selectedModels: (tasks, shouldScroll) ->
			if !@holdModifier?
				@deselectAllTasksButTasks( tasks, true )
			else if @holdModifier is "shift"
				@selectTasksForTasksWithShift( tasks )
		selectTasksForTasksWithShift: ( tasks ) ->
			selectedTask = tasks[0]
			selectTheFollowingTasks = []
			isRunningSelection = false
			shouldTurnOffSelection = false
			for view, i in @subviews
				model = view.model
				if i is @currentToStartFromInShift and model.cid is selectedTask.cid
					selectTheFollowingTasks.push model
				else if i is @currentToStartFromInShift or model.cid is selectedTask.cid
					if !isRunningSelection
						isRunningSelection = true
					else 
						shouldTurnOffSelection = true

				if isRunningSelection
					selectTheFollowingTasks.push model
				if shouldTurnOffSelection
					isRunningSelection = false
			@deselectAllTasksButTasks(selectTheFollowingTasks)
		deselectAllTasksButTasks: (selectedTasks, filter) ->
			if swipy.todos.getSelected().length <= 1 and filter?
				selectedTasks = _.reject( selectedTasks, (m) -> !m.get "selected" )
			if selectedTasks.length is 0
				@setLastIndex(-1, true)
			tasks = @getTasks()
			for task in tasks
				if _.indexOf(selectedTasks, task) is -1
					task.set("selected", false)
				else
					task.set("selected", true)
		handleDidPressTask: ( tasks ) ->
			@selectedModels(tasks)
			model = tasks[0]
			newIndex = 0
			newIndex = i for view, i in @subviews when view.model.cid is model.cid
			if model.get "selected"
				saveToShift = @holdModifier isnt "shift"
				@setLastIndex( newIndex, saveToShift )
					
		render: ->
			@renderList()
			#$("#add-task input").focus()
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
			return if !@$el
			@$el.empty()
			@killSubViews()

			todos = @getTasks()

			# Rejects models filtered out by tag or search
			todos = _.reject( todos, (m) -> m.get( "rejectedByTag" ) or m.get "rejectedBySearch" )

			# Deselect any selected items
			_.invoke( todos, "set", { selected: no } )
			totalNumberOfTasks = 0
			# Handle all done for today background
			if @state is "tasks"
				upcomingTasksToday = swipy.todos.getScheduledLaterToday()
				totalNumberOfTasks += upcomingTasksToday.length
				completedTasksForToday = swipy.todos.getCompletedToday()
				totalNumberOfTasks += completedTasksForToday.length
				currentTasks = swipy.todos.getActive()
				totalNumberOfTasks += currentTasks.length
			if @state is "tasks" and todos.length is 0 and !swipy.filter.hasFilters()
				if upcomingTasksToday.length
					$(".all-done").addClass("for-now")
				else
					$('.all-done').addClass("for-today")
			else
				$(".all-done").removeClass("for-today")
				$(".all-done").removeClass("for-now")


			@beforeRenderList todos

			for group in @groupTasks todos
				tasksJSON = _.invoke( group.tasks, "toJSON" )
				progress = ""
				progress = "no-progress" if @state isnt "tasks"
			
				title = group.deadline

				# Find the current progress
				if @state is "tasks"
					if !totalNumberOfTasks
						percentage = 100
					else
						percentage = parseInt(completedTasksForToday.length / totalNumberOfTasks*100)
					
					if totalNumberOfTasks
						title = completedTasksForToday.length + " / " + totalNumberOfTasks + " Tasks"
				lastPercentage = percentage
				if @lastPercentage?
					lastPercentage = @lastPercentage
				$html = $( @template { title: title, tasks: tasksJSON, state: @state, progress: progress, jQuery: $, percentage: lastPercentage} )
				@lastPercentage = percentage
				list = $html.find "ol"
				for model in group.tasks
					view = if Modernizr.touch then new TouchTaskView( { model } ) else new DesktopTaskView( { model } )
					view.delegate = @
					@subviews.push view
					list.append view.el

				@$el.append $html
				widthOfText = $html.find('h1 > span').innerWidth()

				actualWidth = widthOfText + 50
				$html.find('.progress').parent().css("paddingRight",actualWidth+"px")
				$html.find('h1').css("width",actualWidth+"px")
				shapePadding = actualWidth*1.025
				$html.find('.shapeline').css("right",shapePadding+"px")
				if @state is "tasks"
					$html.find('.progress-bar').css("width",percentage+"%")
			@afterRenderList todos

			if swipy.filter.hasFilters()
				$('.search-result').removeClass("hidden")
			else
				$('.search-result').addClass("hidden")
			swipy.filter.updateFilterString(todos.length)
		pressedTask:(model) ->
			if !@holdModifier and !@$el.hasClass("selecting")
				identifier = model.id
				swipy.router.navigate( "edit/#{ identifier }", yes )
			else
				currentlySelected = model.get( "selected" ) or false
				model.set( "selected", !currentlySelected )
				Backbone.trigger( "did-press-task", [model])
		beforeRenderList: (todos) ->
		afterRenderList: (todos) ->
			newSelectIndex = -1
			if @shouldSelectNext? and @shouldSelectNext
				@shouldSelectNext = false
				if @lastSelectedIndex isnt -1
					searchIndex = @lastSelectedIndex
					searchIndex = @subviews.length-1 if @lastSelectedIndex >= @subviews.length
					selectNewModel = view.model for view, i in @subviews when i is searchIndex
					if selectNewModel
						newSelectIndex = searchIndex
						selectNewModel.set "selected", true
						@selectedModels([selectNewModel])
			if @shouldResetLast? and @shouldResetLast
				@shouldResetLast = false
				@setLastIndex(newSelectIndex,true)
				
			
		afterMovedItems: ->
			
		getViewForModel: (model) ->
			return view for view in @subviews when view.model.cid is model.cid

		completeTasks: (model, shouldSelectNext) ->
			@shouldResetLast = true
			if shouldSelectNext
				@shouldSelectNext = true

			tasks = swipy.todos.getSelected( model )
			return if tasks.length is 0
			minOrder = Math.min _.invoke( tasks, "get", "order" )...

			# Bump order for tasks
			swipy.todos.bumpOrder( "up", minOrder, tasks.length )
			for task in tasks
				view = @getViewForModel task
				self = @
				# Wrap in do, so reference to model isn't changed next time the loop iterates
				compFunc = _.debounce(->
					self.afterMovedItems()
				, 10)
				if view? then do =>
					m = task
					view.swipeRight( "completed" ).then =>
						m.completeTask()
						compFunc()

			swipy.analytics.sendEvent("Tasks", "Completed", "",  tasks.length)
			swipy.analytics.sendEventToIntercom("Completed Tasks", {"Number of Tasks": tasks.length })
			
		markTasksAsTodo: (model, shouldSelectNext) ->
			@shouldResetLast = true
			if shouldSelectNext
				@shouldSelectNext = true
			tasks = swipy.todos.getSelected( model )
			return if tasks.length is 0
			for task in tasks
				view = @getViewForModel task
				self = @
				# Wrap in do, so reference to model isn't changed next time the loop iterates
				if view? then do ->
					m = task
					oldState = m.previous("state")
					compFunc = _.debounce(->
						self.afterMovedItems()
					, 10)
					if oldState is "scheduled"
						view.swipeRight("todo").then ->
							m.scheduleTask m.getDefaultSchedule()
							compFunc()
					else
						view.swipeLeft("todo").then ->
							m.scheduleTask m.getDefaultSchedule()
							compFunc()

		scheduleTasks: (model, shouldSelectNext) ->
			@shouldResetLast = true
			if shouldSelectNext
				@shouldSelectNext = true
			tasks = swipy.todos.getSelected( model )
			return if tasks.length is 0
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
			@lastSelectedIndex = -1
			@actionbar = new ActionBar({state: @state})
			@transitionDeferred.resolve()
			swipy.shortcuts.setDelegate( @ )
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
			$('.search-result').addClass("hidden")
			@lastSelectedIndex = -1
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
