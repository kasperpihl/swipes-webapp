define [
	"underscore"
	"gsap"
	"js/viewcontroller/TaskListViewController"
	"js/viewcontroller/ChatListViewController"
	], (_, TweenLite, TaskListViewController, ChatListViewController) ->
	Backbone.View.extend
		className: "my-tasks-view-controller"
		initialize: ->

		render: ->
			@$el.html ""
			$("#main").html(@$el)

			swipy.rightSidebarVC.reload()
			@loadMainWindow(@mainView)
		
		open: (options) ->

			@mainView = "task"
			swipy.rightSidebarVC.sidebarDelegate = @
			swipy.topbarVC.setMainTitleAndEnableProgress("My Tasks", false )

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
			taskListVC.taskList.enableDragAndDrop = true
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
			RightSidebarDelegate
		###
		sidebarSwitchToView: (sidebar, view) ->
			if @mainView is "task"
				@mainView = "chat" 
			else @mainView = "task"
			@render()
		sidebarGetViewController: (sidebar) ->
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