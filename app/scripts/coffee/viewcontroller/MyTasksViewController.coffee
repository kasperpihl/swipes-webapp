define [
	"underscore"
	"gsap"
	"js/viewcontroller/TaskListViewController"
	"js/viewcontroller/ChatListViewController"
	"js/utility/TimeUtility"
	"momentjs"
	], (_, TweenLite, TaskListViewController, ChatListViewController, TimeUtility) ->
	Backbone.View.extend
		className: "my-tasks-view-controller main-view-controller"
		initialize: ->
			@timeUtil = new TimeUtility()
		render: ->
			@$el.html ""
			$("#main").html(@$el)

			swipy.rightSidebarVC.reload()
			@loadMainWindow(@mainView)
		
		open: (options) ->

			@mainView = "task"
			swipy.rightSidebarVC.sidebarDelegate = @
			swipy.topbarVC.setMainTitleAndEnableProgress("My Tasks", false )
			swipy.rightSidebarVC.loadSidemenu("navbarChat") if !swipy.rightSidebarVC.activeClass?
			@render()

		loadMainWindow: (type) ->
			@vc?.destroy()
			if type is "task"
				@vc = @getTaskListVC()
			else if type is "chat"
				@vc = @getChatListVC()
			else return
			@$el.html @vc.el
			@vc.render()


		getTaskListVC: ->
			taskListVC = new TaskListViewController()
			taskListVC.addTaskCard.addDelegate = @
			taskListVC.taskList.showSource = true
			taskListVC.taskHandler.listSortAttribute = "order"
			taskListVC.taskHandler.delegate = @
			taskListVC.addTaskCard.setPlaceHolder("Add Personal Task")

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
		getChatListVC: ->
			@chatCollectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.messages,
				filter: (message) ->
					if (message.get("userId") is Parse.User.current().id and message.get("toUserId") is Parse.User.current().id)
						return true
					return false
			})
			chatListVC = new ChatListViewController()
			chatListVC.newMessage.addDelegate = @
			chatListVC.chatHandler.loadCollection(@chatCollectionSubset.child)
			chatListVC.newMessage.setPlaceHolder("Send message to self")
			return chatListVC


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
					title = "Your Current Tasks"
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
			RightSidebarDelegate
		###
		sidebarSwitchToView: (sidebar, view) ->
			if view is "navbarChat"
				@mainView = "chat"
			else @mainView = "task"
			@render()
		sidebarGetViewController: (sidebar, view) ->
			if @mainView is "task"
				return @getChatListVC()
			else
				return @getTaskListVC()

		###
			NewMessage Delegate
		###
		newMessageSent: ( newMessage, message ) ->
			options = {}
			options.toUserId = Parse.User.current().id
			Backbone.trigger("send-message", message, options)
			Backbone.trigger("reload/chathandler")
		###
			AddTaskCard Delegate
		###
		taskCardDidCreateTask: ( taskCard, title, options) ->
			options = {} if !options
			options.toUserId = Parse.User.current().id
			now = new Date()
			now.setSeconds now.getSeconds() - 1
			options.schedule = now
			Backbone.trigger("create-task", title, options)
			Backbone.trigger("reload/taskhandler")

		destroy: ->
			@vc?.destroy()