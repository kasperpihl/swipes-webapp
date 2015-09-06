define [
	"underscore"
	"js/view/list/ActionBar"
	"js/view/list/DesktopTask"
	"js/view/list/TouchTask"
	"text!templates/todo-list.html"
	"js/model/extra/ScheduleModel"
	"mousetrapGlobal"
	"gsap-scroll" 
	"gsap"
	], (_, ActionBar, DesktopTaskView, TouchTaskView, ToDoListTmpl, ScheduleModel) ->
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

			@listenTo( Backbone, "sync-complete", @syncCompleted )
			@listenTo( swipy.collections.todos, "add remove reset change:priority change:completionDate change:schedule change:rejectedByTag change:rejectedBySearch change:subtasksLocal", @renderList )
			#@listenTo( swipy.collections.todos, "change:order", @changedOrder )

			# Handle task actions
			@listenTo( Backbone, "complete-task", @completeTasks )
			@listenTo( Backbone, "todo-task", @markTasksAsTodo )
			@listenTo( Backbone, "schedule-task", @scheduleTasks )
			@listenTo( Backbone, "scheduler-cancelled", @handleSchedulerCancelled )
			@listenTo( Backbone, "schedule-all-but-selected", @scheduleAllTasksButSelected )

			@listenTo( Backbone, "did-press-task", @handleDidPressTask )
			@listenTo( Backbone, "pick-schedule-option", @snoozedATask )
			# Re-render list once per minute, activating any scheduled tasks.
			@listenTo( Backbone, "clockwork/update", @moveTasksToActive )

			Mousetrap.bindGlobal( "mod+a", $.proxy( @selectAllTasks, @ ) )
			_.bindAll( @, "keyDownHandling", "keyUpHandling", "selectTasksForTasksWithShift", "clearForOpening", "longPressHandling", "snoozedATask", "changedOrder", "syncCompleted" )
			@setLastIndex( -1, true )
			@shouldResetLast = false
			@render()


		syncCompleted: (todos) ->
			if todos and todos.length > 0
				tasks = @getTasks()
				for task in tasks
					if _.indexOf( todos, task.id ) isnt -1
						@renderList()
						return
		changedOrder: ->
			@longBounceRenderList()
		snoozedATask: ->
			@afterMovedItems()
		clearForOpening: ->
			@holdModifier = null
			$('.todo-list').removeClass("cmd-down")
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
		handleClick: (e) ->
			@deselectAllTasksButTasks([])
		keyDownHandling: (e) ->
			return if $("input").is(":focus")

			if e.keyCode is 32
				e.preventDefault()
			
			
			# cmd / ctrl
			if(e.metaKey or e.ctrlKey)
				$('.todo-list').addClass("cmd-down")
				@holdModifier = "cmd"

			# shift key
			if e.shiftKey
				@holdModifier = "shift";
				
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
					saveToShift = !e.shiftKey
					@setLastIndex( index, saveToShift )
					@selectedModels([task], e)
					
					# Handle auto scroll
					scrollableView = $(".task-list-view-controller")
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
		holdModifierForEvent: (e) ->
			return null if !e? or !e
			return "shift" if @holdModifier is "shift" and e.shiftKey
			return "cmd" if @holdModifier is "cmd" and e.ctrlKey or e.metaKey

			return "shift" if e.shiftKey
			return "cmd" if e.ctrlKey or e.metaKey
			return null
		clearLongPress: ->
			@didHitALongPress = false
			@currentLongPressKey = null
			@currentLongPressCount = 0
		keyUpHandling: (e) ->
			return if $("input").is(":focus")
			if e.keyCode is 27
				@deselectAllTasksButTasks([])
			if !e.metaKey and !e.ctrlKey
				$('.todo-list').removeClass("cmd-down")
				
			if e.keyCode is 32
				swipy.router.navigate("add",true )
			if e.keyCode is 13
				@openSelectedTask()
				
			# left arrow / right arrow
			if e.keyCode is 37 or e.keyCode is 39
				if @currentLongPressKey?
					if @currentLongPressKey is e.keyCode
						if !@didHitALongPress
							@actionForDirection(e, false)
						@clearLongPress()
			
					
		openSelectedTask: ->
			lastTask = view.model for view, i in @subviews when i is @lastSelectedIndex
			if lastTask and swipy.collections.todos.getSelected().length > 0
				@openTask(lastTask)
		selectedModels: (tasks, e) ->
			holdModifier = @holdModifierForEvent(e)
			if !holdModifier?
				@deselectAllTasksButTasks( tasks, true )
			else if holdModifier is "shift"
				@selectTasksForTasksWithShift( tasks )
		selectTasksForTasksWithShift: ( tasks ) ->
			selectedTask = tasks[0]
			selectTheFollowingTasks = []
			isRunningSelection = false
			shouldTurnOffSelection = false
			if @currentToStartFromInShift is -1
				@currentToStartFromInShift = 0
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
			if swipy.collections.todos.getSelected().length <= 1 and filter?
				selectedTasks = _.reject( selectedTasks, (m) -> !m.get "selected" )
			if selectedTasks.length is 0
				@setLastIndex(-1, true)
			tasks = @getTasks()
			for task in tasks
				if _.indexOf(selectedTasks, task) is -1
					task.set("selected", false)
				else
					task.set("selected", true)
		handleDidPressTask: ( tasks, e ) ->
			@selectedModels(tasks, e)
			model = tasks[0]
			newIndex = 0
			newIndex = i for view, i in @subviews when view.model.cid is model.cid
			if model.get "selected"
				saveToShift = @holdModifierForEvent(e) isnt "shift"
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
			return swipy.collections.todos.getActive()
		
		selectAllTasks: (e) ->
			# Prevent default (select all text on page || select all text in input), unless input is focused AND have text input.
			taskInput = $("#add-task textarea")
			unless taskInput.val() and taskInput.is ":focus"
				e.preventDefault()
				tasks = @getTasks()
				doSelect = _.any tasks, (task) -> not task.get("selected")
				_.invoke( tasks, "set", "selected", doSelect )
		moveTasksToActive: ->
			now = new Date().getTime()
			# Get all tasks that are scheduled within the current 1001ms
			# (Includes stuff moved from completed, which is defaulting to 1000ms in the past)
			return if @state is "done"
			
			self = @
			movedFromScheduled = _.filter @getTasks(), (m) ->
				return false unless m.has "schedule"
				if self.state is "tasks"
					return m.get("state") isnt "active"
				else return m.get( "schedule" ).getTime() < now
			# If we have tasks then bump all tasks +1 and
			# set order: 0 and animateIn: yes for all of them
			if movedFromScheduled.length
				if @state is "tasks"
					_.invoke( movedFromScheduled, "set", { order: -1, animateIn: yes } )

				# After changes, re-render the list
				@renderList()
		renderList: ->
			# Remove any old HTML before appending new stuff.
			return if !@$el
			oldScroll = $("#scrollcont").scrollTop()
			if typeof(Storage) isnt "undefined" and localStorage.getItem("saved-offset-list-" + @state)
				oldScroll = localStorage.getItem("saved-offset-list-" + @state)
				localStorage.removeItem("saved-offset-list-" + @state)

			@$el.empty()
			@killSubViews()

			todos = @getTasks()

			# Rejects models filtered out by tag or search
			todos = _.reject( todos, (m) -> m.get( "rejectedByTag" ) or m.get "rejectedBySearch" )

			

			# Handle all done for today background
			totalNumberOfTasks = 0
			if @state is "tasks"
				upcomingTasksToday = swipy.collections.todos.getScheduledLaterToday()
				totalNumberOfTasks += upcomingTasksToday.length
				completedTasksForToday = swipy.collections.todos.getCompletedToday()
				totalNumberOfTasks += completedTasksForToday.length
				currentTasks = swipy.collections.todos.getActive()
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
				title = title.charAt(0).toUpperCase() + title.slice(1);

				# Find the current progress
				if @state is "tasks"
					if !totalNumberOfTasks
						percentage = 100
					else
						percentage = parseInt(completedTasksForToday.length / totalNumberOfTasks*100)
					
					if totalNumberOfTasks
						title = completedTasksForToday.length + " / " + totalNumberOfTasks + " Done Today"
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

				if !@organisebar? or !@organisebar
					widthOfText = $html.find('h1 > span').text().length * 9
					#console.log $html.find('h1 > span').html() + " " + widthOfText
					actualWidth = widthOfText + 50

					$html.find('.progress').parent().css("paddingRight",actualWidth+"px")
					$html.find('h1').css("width",actualWidth+"px")
					shapePadding = actualWidth*1.025
					$html.find('.shapeline').css("right",shapePadding+"px")
					if @state is "tasks"
						$html.find('.progress-bar').css("width",percentage+"%")
			@afterRenderList todos

			$("#scrollcont").scrollTop(oldScroll)
			
			if swipy.filter.hasFilters()
				$('.search-result').removeClass("hidden")
			else
				$('.search-result').addClass("hidden")
			swipy.filter.updateFilterString(todos.length)
		saveOffset: ->
			@savedOffset = $("#scrollcont").scrollTop()
			if typeof(Storage) isnt "undefined"
				localStorage.setItem("saved-offset-list-" + @state, @savedOffset)
		openTask:(model) ->
			@saveOffset()
			identifier = model.id
			swipy.router.navigate( "edit/#{ identifier }", yes )
		pressedTask:(model, e) ->
			isOrganising = $("body").hasClass("organise")

			holdModifier = @holdModifierForEvent(e)
			if !isOrganising and !holdModifier and !@$el.hasClass("selecting")
				@openTask(model)
			else
				currentlySelected = model.get( "selected" ) or false
				model.set( "selected", !currentlySelected )
				Backbone.trigger( "did-press-task", [model], e) if !isOrganising
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
			swipy.sidebar.organisebar?.toggle()
			
		afterMovedItems: ->
			swipy.collections.todos.deselectAllTasks()

		getViewForModel: (model) ->
			return view for view in @subviews when view.model.cid is model.cid

		completeTasks: (model, shouldSelectNext) ->
			@shouldResetLast = true
			if shouldSelectNext
				@shouldSelectNext = true

			tasks = swipy.collections.todos.getSelected( model )
			return if tasks.length is 0
			#minOrder = Math.min _.invoke( tasks, "get", "order" )...

			# Bump order for tasks
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

			swipy.analytics.sendEventToIntercom("Completed Tasks", {"Number of Tasks": tasks.length })
			
		markTasksAsTodo: (model, shouldSelectNext) ->
			@shouldResetLast = true
			if shouldSelectNext
				@shouldSelectNext = true
			tasks = swipy.collections.todos.getSelected( model )
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

		scheduleAllTasksButSelected: ->
			tasksToSchedule = _.filter @getTasks(), (m) ->
				return !m.get("selected")
			model = new ScheduleModel()
			dateToSchedule = model.getDateFromScheduleOption("tomorrow")
			for task in tasksToSchedule
				view = @getViewForModel task
				self = @
				# Wrap in do, so reference to model isn't changed next time the loop iterates
				compFunc = _.debounce(->
					self.afterMovedItems()
					swipy.sidebar.organisebar.success()
				, 10)
				if view? then do =>
					m = task
					view.swipeLeft( "scheduled" ).then =>
						m.scheduleTask(dateToSchedule)
						compFunc()

		scheduleTasks: (model, shouldSelectNext) ->
			@shouldResetLast = true
			if shouldSelectNext
				@shouldSelectNext = true
			tasks = swipy.collections.todos.getSelected( model )
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
		transitionInComplete:(options) ->
			@lastSelectedIndex = -1
			@actionbar = new ActionBar({state: @state})
			
			@transitionDeferred.resolve()
			$('.todo-list').removeClass("cmd-down")
			return if options? and options.onlyInstantiate
			swipy.shortcuts.setDelegate( @ )
			if options and options.action is "organise"
				Backbone.trigger("show-organise")
				@organisebar = true
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
			swipy.collections.todos.invoke( "set", { selected: no } )

			# Run clean-up routine on sub views
			@killSubViews()
