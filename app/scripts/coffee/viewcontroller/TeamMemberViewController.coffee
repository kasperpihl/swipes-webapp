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
			console.log _.pluck(collection.toJSON(), "user")
			@currentList = collection.findWhere({is_im: true, user: @currentUser.id})

			swipy.topbarVC.setMainTitleAndEnableProgress(@currentUser.get("name"), false)
			swipy.rightSidebarVC.loadSidemenu("navbarChat") if !swipy.rightSidebarVC.activeClass?
			@render()	

		taskHandlerSortAndGroupCollection: (taskHandler, collection) ->
			self = @
			meUser = swipy.slackCollections.users.me()
			groups = collection.groupBy((model, i) ->
				# TODO: Seperate tasks between who it's from
				if model.get("toUserId") is meUser.id
					return "My Tasks"
				else 
					return "His Tasks"
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
			options.toUserId = @currentUser.id if !options.toUserId?
			options.projectLocalId = @currentList.id
			#options.ownerId = @currentUser.get("organisationId")
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
			taskListVC.addTaskCard.setPlaceHolder("Send task to " + @currentUser.get("name"))

			# https://github.com/anthonyshort/backbone.collectionsubset
			projectId = @currentList.id
			meUser = swipy.slackCollections.users.me()
			@taskCollectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					if !task.get("completionDate") and !task.isSubtask()
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
			chatListVC.newMessage.setPlaceHolder("Send message to " + @currentUser.get("name"))
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
			Backbone.trigger("mark-read", "member-"+@memberId, timestamp)

		
		###
			NewMessage Delegate
		###
		newMessageSent: ( newMessage, message ) ->
			options = { type:"message", channel: @currentList.id, text: message, user: swipy.slackCollections.users.me().id }
			swipy.slackSync.doSocketSend( options )
			@chatListVC.chatList.scrollToBottomVar = true
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