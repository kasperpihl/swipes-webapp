define [
	"underscore"
	"gsap"
	"js/viewcontroller/TaskListViewController"
	"js/utility/TimeUtility"
	"momentjs"
	"collectionSubset"
	], (_, TweenLite, TaskListViewController, TimeUtility) ->
	Backbone.View.extend
		className: "my-tasks-view-controller main-view-controller"
		initialize: ->
			@timeUtil = new TimeUtility()
			Backbone.on( "create-task", @createTask, @ )
			Backbone.on( "clicked/section", @clickedSection, @)
		render: ->
			@$el.html ""
			$("#main").html(@$el)

			swipy.rightSidebarVC.reload()
			@loadMainWindow(@mainView)
		
		open: (type, options) ->

			@mainView = "task"
			swipy.rightSidebarVC.sidebarDelegate = @
			@showSomedayMaybe = false
			@showLaterTasks = false
			@showCompletedTasks = false

			swipy.topbarVC.setMainTitleAndEnableProgress("My Tasks", false )
			swipy.rightSidebarVC.hideSidemenu()
			@render()
		loadMainWindow: (type) ->
			@vc?.destroy()
			if type is "task"
				@vc = @getTaskListVC()
			else return
			@$el.html @vc.el
			@vc.render()

		createTask: ( title, options ) ->
			me = swipy.slackCollections.users.me()
			options = {} if !options
			options.toUserId = me.id if !options.toUserId?
			now = new Date()
			now.setSeconds now.getSeconds() - 1
			options.schedule = now if !options.schedule?
			@taskCollectionSubset?.child.createTask(title, options)
			@taskListVC?.taskHandler.bouncedReloadWithEvent()

		getTaskListVC: ->
			# https://github.com/anthonyshort/backbone.collectionsubset
			@taskCollectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					if !task.isSubtask()
						if task.get("isMyTask")
							return true
					return false
			})

			@taskListVC = new TaskListViewController
				delegate: @
				isMyTasksView: true
				collectionToLoad: @taskCollectionSubset.child
		
		clickedSection: (section) ->
			if section is "future-tasks"
				@showLaterTasks = true
			else if section is "someday-maybe"
				@showSomedayMaybe = true
			else if section is "completed-tasks"
				@taskListVC?.scrollToTop()
				@showCompletedTasks = true
			else if section is "hide-completed-tasks"
				@showCompletedTasks = false
			@taskListVC?.taskHandler.bouncedReloadWithEvent()
			

		###
			TaskHandler Delegate
		###
		taskHandlerSortAndGroupCollection: (taskHandler, collection, toggleComplete) ->
			self = @
			tasks = collection.models
			if @showCompletedTasks
				tasks = _.filter collection.models, (m) -> m.get("completionDate")

			groups = _.groupBy(tasks, (model, i) =>
				if model.get("completionDate")
					if @showCompletedTasks then return moment(model.get("completionDate")).startOf('day').unix()
					else return 9999999999
				if model.getState() is "active" then return -1
				else if model.getState() is "scheduled"
					schedule = model.get("schedule")
					return 9999999998 if !schedule? or !schedule
					return 9999999997 if !@showLaterTasks
					return moment(schedule).startOf('day').unix()
			)
			
			taskGroups = []
			sortedKeys = _.keys(groups).sort()

			if @showCompletedTasks
				sortedKeys = sortedKeys.reverse()
			
			for key in sortedKeys
				dontSort = false
				includeTasks = true
				expandClass = false
				tasks = groups[key]
				numberOfTasksForSection = tasks.length
				if key is "-1"
					title = "Your tasks"
				else if key is "9999999997"
					title = "Future Tasks ( " + numberOfTasksForSection + " )"
					includeTasks = false
					expandClass = "future-tasks"
				else if key is "9999999998"
					title = "Someday/Maybe"
					if !@showSomedayMaybe
						title += " ( " + numberOfTasksForSection + " )"
						includeTasks = false
						expandClass = "someday-maybe"
				else if key is "9999999999"
					title = "Completed Tasks ( " + numberOfTasksForSection + " )"
					includeTasks = false
					expandClass = "completed-tasks"
				else
					dontSort = true
					showSchedule = true
					schedule = new Date(parseInt(key)*1000)
					groups[key] = _.sortBy(groups[key], (model) =>
						return -model.get("completionDate").getTime() if @showCompletedTasks
						return model.get("schedule")?.getTime()
					)
					title = @timeUtil.dayStringForDate(schedule)
					if @showCompletedTasks
						title = "Completed " + title
					else if title is "Today"
						title = "Later Today"
				group = {showSource: true, showSchedule: showSchedule, leftTitle: title, dontSort: dontSort, expandClass: expandClass }
				group.tasks = tasks if includeTasks
				taskGroups.push(group)
			if @showCompletedTasks and taskGroups.length
				taskGroups = [{leftTitle:"Hide completed tasks", "expandClass": "hide-completed-tasks"}].concat( taskGroups )
			return taskGroups


		###
			AddTaskCard Delegate
		###
		taskCardDidCreateTask: ( taskCard, title, options) ->
			@createTask( title, options )

		destroy: ->
			@taskListVC?.destroy()
			Backbone.off(null,null, @)
			@vc?.destroy()