define [
	"underscore"
	"gsap"
	"js/viewcontroller/TaskListViewController"
	"js/utility/TimeUtility"
	"momentjs"
	], (_, TweenLite, TaskListViewController, TimeUtility) ->
	Backbone.View.extend
		className: "my-tasks-view-controller main-view-controller"
		initialize: ->
			@timeUtil = new TimeUtility()
			Backbone.on( "create-task", @createTask, @ )
		render: ->
			@$el.html ""
			$("#main").html(@$el)

			swipy.rightSidebarVC.reload()
			@loadMainWindow(@mainView)
		
		open: (options) ->

			@mainView = "task"
			swipy.rightSidebarVC.sidebarDelegate = @
			swipy.topbarVC.setMainTitleAndEnableProgress("My Tasks", false )
			swipy.rightSidebarVC.hideSidemenu()
			@render()
			if swipy.onboarding.getCurrentEvent() is "WaitingForMyTasks"
				swipy.onboarding.setCurrentEvent("DidOpenMyTasks",true)
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
			Backbone.trigger("reload/taskhandler")

		getTaskListVC: ->
			taskListVC = new TaskListViewController()
			taskListVC.addTaskCard.addDelegate = @
			taskListVC.taskList.showSource = true
			taskListVC.taskHandler.listSortAttribute = "order"
			taskListVC.taskHandler.delegate = @
			taskListVC.taskList.emptyTitle = "No tasks in your workspace"
			taskListVC.taskList.emptySubtitle = "You can add Personal tasks below or assign tasks from channels and groups."
			taskListVC.taskList.emptyDescription = "Tasks here is the ones assigned to you. Here you can get an overview of your commitments and put it all in order."
			
			taskListVC.addTaskCard.setPlaceHolder("Add a new personal task")

			# https://github.com/anthonyshort/backbone.collectionsubset
			@taskCollectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					if !task.get("completionDate") and !task.isSubtask()
						if task.get("isMyTask")
							return true
					return false
			})
			taskListVC.taskHandler.loadCollection(@taskCollectionSubset.child)

			return taskListVC
		
		###
			TaskHandler Delegate
		###
		taskHandlerSortAndGroupCollection: (taskHandler, collection) ->
			self = @

			groups = collection.groupBy((model, i) ->
				if model.getState() is "active" then return -1
				else if model.getState() is "scheduled"
					schedule = model.get("schedule")
					return 9999999999 if !schedule? or !schedule
					return moment(schedule).startOf('day').unix()
			)
			taskGroups = []
			sortedKeys = _.keys(groups).sort()
			for key in sortedKeys
				dontSort = false
				showSchedule = false
				if key is "-1"
					title = "Your current tasks"
				else if key is "9999999999"
					title = "Unspecified"
				else
					dontSort = true
					showSchedule = true
					schedule = new Date(parseInt(key)*1000)
					groups[key] = _.sortBy(groups[key], (model) ->
						return model.get("schedule")?.getTime()
					)
					title = @timeUtil.dayStringForDate(schedule)
					title = "Later Today" if title is "Today"
				taskGroups.push({showSource: true, showSchedule: showSchedule, leftTitle: title, tasks: groups[key], dontSort: dontSort })
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