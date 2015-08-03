define [
	"underscore"
	"gsap"
	"js/viewcontroller/TaskListViewController"
	"js/viewcontroller/ChatListViewController"
	], (_, TweenLite, TaskListViewController, ChatListViewController) ->
	Backbone.View.extend
		className: "team-member-view-controller main-view-controller"
		initialize: ->
			Backbone.on( "create-task", @createTask, @ )
		render: ->
			@$el.html ""
			$("#main").html(@$el)

			swipy.rightSidebarVC.reload()
			@loadMainWindow(@mainView)
			

		open: (options) ->
			@memberId = options.id
			@mainView = "task"
			
			swipy.rightSidebarVC.sidebarDelegate = @

			@currentMember = swipy.collections.members.get(@memberId)
			swipy.topbarVC.setMainTitleAndEnableProgress(@currentMember.get("username"), false)
			swipy.rightSidebarVC.loadSidemenu("navbarChat") if !swipy.rightSidebarVC.activeClass?
			@render()	

		taskHandlerSortAndGroupCollection: (taskHandler, collection) ->
			self = @
			groups = collection.groupBy((model, i) ->
				# TODO: Seperate tasks between who it's from
				if model.get("toUserId") is self.currentMember.id
					return "His Tasks"
				else 
					return "My Tasks"
			)
			taskGroups = []
			taskGroups.push({leftTitle: "RECEIVED TASKS" , tasks: groups["My Tasks"]}) #if groups["My Tasks"]?.length > 0
			taskGroups.push({rightTitle: "SENT TASKS", tasks: groups["His Tasks"]}) #if groups["His Tasks"]?.length > 0
			
			return taskGroups



		loadMainWindow: (type) ->
			@vc?.destroy()
			if type is "task"
				@vc = @getTaskListVC()
			else if type is "chat"
				@vc = @getChatListVC()
			else return
			@$el.html @vc.el
			@vc.render()

		createTask: ( title, options ) ->
			options = {} if !options
			options.toUserId = @currentMember.id if !options.toUserId?
			options.ownerId = @currentMember.get("organisationId")
			@taskCollectionSubset?.child.createTask(title, options)
			Backbone.trigger("reload/taskhandler")


		### 
			Get A TaskListViewController that filtered for this project
		###
		getTaskListVC: ->
			taskListVC = new TaskListViewController()
			taskListVC.addTaskCard.addDelegate = @
			taskListVC.taskHandler.listSortAttribute = "projectOrder"
			taskListVC.taskHandler.delegate = @
			taskListVC.addTaskCard.setPlaceHolder("Send task to " + @currentMember.get("username"))

			# https://github.com/anthonyshort/backbone.collectionsubset
			memberId = @memberId
			@taskCollectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					if !task.get("completionDate") and !task.isSubtask()
						if (task.get("userId") is Parse.User.current().id and task.get("toUserId") is memberId) or (task.get("userId") is memberId and task.get("toUserId") is Parse.User.current().id)
							return true
					return false
			})
			taskListVC.taskHandler.loadCollection(@taskCollectionSubset.child)
			@taskListVC = taskListVC
			return taskListVC


		### 
			Get A ChatListViewController that filtered for this project
		###
		getChatListVC: ->
			memberId = @memberId
			@chatCollectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.messages,
				filter: (message) ->
					if (message.get("userId") is Parse.User.current().id and message.get("toUserId") is memberId) or (message.get("userId") is memberId and message.get("toUserId") is Parse.User.current().id)
						return true
					return false
			})
			chatListVC = new ChatListViewController()
			chatListVC.newMessage.addDelegate = @
			chatListVC.chatList.delegate = @
			chatListVC.newMessage.setPlaceHolder("Send message to " + @currentMember.get("username"))
			chatListVC.chatHandler.loadCollection(@chatCollectionSubset.child)
			@chatListVC = chatListVC
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
			ChatList ChatDelegate
		###
		chatListMarkAsRead: (chatList, timestamp) ->
			Backbone.trigger("mark-read", "member-"+@memberId, timestamp)

		
		###
			NewMessage Delegate
		###
		newMessageSent: ( newMessage, message ) ->
			options = {}
			options.toUserId = @currentMember.id
			options.ownerId = @currentMember.get("organisationId")
			@chatCollectionSubset?.child.sendMessage(message, options)
			@chatListVC.chatList.scrollToBottomVar = true
			Backbone.trigger("reload/chathandler", "scrollToBottom")
		###
			AddTaskCard Delegate
		###
		taskCardDidCreateTask: ( taskCard, title, options) ->
			@createTask(title, options)

		destroy: ->
			@chatListVC?.destroy()
			@taskListVC?.destroy()
			Backbone.off( null, null, @ )
			@vc?.destroy()