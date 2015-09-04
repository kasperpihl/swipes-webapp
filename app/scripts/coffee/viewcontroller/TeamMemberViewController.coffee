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
			@identifier = options.id
			@type = "im"

			@mainView = "chat"
			
			swipy.rightSidebarVC.sidebarDelegate = @

			collection = swipy.slackCollections.channels
			
			@currentUser = swipy.slackCollections.users.findWhere({name: @identifier})
			
			@currentList = collection.findWhere({is_im: true, user: @currentUser.id})
			name = @currentUser.get("name")
			name = "slackbot & sofi" if name is "slackbot"
			swipy.topbarVC.setMainTitleAndEnableProgress(name, false)
			swipy.rightSidebarVC.loadSidemenu("navbarChat") if !swipy.rightSidebarVC.activeClass?
			@render()	

		taskHandlerSortAndGroupCollection: (taskHandler, collection) ->
			self = @
			title =  "You & " + @currentUser.get("name") + "'s tasks"
			if @currentUser.get("name") is "slackbot"
				title = "You, slackbot & sofi's tasks"
			taskGroups = [{leftTitle: title, tasks: _.filter(collection.models, (m) -> !m.get("completionDate"))}]
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
			options.targetUserId = @currentUser.id
			options.projectLocalId = @currentList.id
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
			taskListVC.taskList.emptyTitle = "No Direct Tasks between you & " + @currentUser.get("name")
			taskListVC.taskList.emptySubtitle = "You can add them below or you can drag a message to here."
			taskListVC.taskList.emptyDescription = "Tasks here will only be visible between you and " + @currentUser.get("name") + ". You can assign tasks to either you or " + @currentUser.get("name") + " and it will be sent into your workspaces."
			taskListVC.addTaskCard.setPlaceHolder("Add a new task between you & " + @currentUser.get("name"))

			if @currentUser.get("name") is "slackbot"
				taskListVC.taskList.emptyTitle = "No Direct Tasks between you, slackbot & sofi"
				taskListVC.taskList.emptyDescription = "Tasks here will only be visible between you, slackbot & sofi. You can assign tasks to you or slackbot, but he probably won't do them!"
				taskListVC.addTaskCard.setPlaceHolder("Add a new task between you, slackbot & sofi")
			

			# https://github.com/anthonyshort/backbone.collectionsubset
			projectId = @currentList.id
			meUser = swipy.slackCollections.users.me()
			@taskCollectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					if !task.isSubtask()
						if (task.get("projectLocalId") is projectId)
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
			memberId = @identifier
			@currentList.fetchMessages()

			chatListVC = new ChatListViewController()
			chatListVC.newMessage.addDelegate = @
			chatListVC.chatList.delegate = @
			chatListVC.newMessage.setPlaceHolder("Send a message to " + @currentUser.get("name"))
			if @currentUser.get("name") is "slackbot"
				chatListVC.newMessage.setPlaceHolder("Send a message to slackbot & sofi")
			chatListVC.chatList.lastRead = parseInt(@currentList.get("last_read"))
			chatListVC.chatHandler.loadCollection(@currentList.get("messages"))
			
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
			@currentList.markAsRead()

		
		###
			NewMessage Delegate
		###
		newMessageSent: ( newMessage, message ) ->
			swipy.slackSync.sendMessage( message, @currentList.id)
			@chatListVC.chatList.scrollToBottomVar = true
			@chatListVC.chatList.removeUnreadIfSeen = true
		newMessageIsTyping: (newMessage ) ->
			options = {type: "typing", channel: @currentList.id }
			swipy.slackSync.doSocketSend(options, true)
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