define [
	"underscore"
	"gsap"
	"js/viewcontroller/TaskListViewController"
	"js/viewcontroller/ChatListViewController"
	
	], (_, TweenLite, TaskListViewController, ChatListViewController) ->
	Backbone.View.extend
		className: "project-view-controller main-view-controller"
		initialize: ->
			Backbone.on( "create-task", @createTask, @ )
		render: (el) ->
			@$el.html ""
			$("#main").html(@$el)
			
			swipy.rightSidebarVC.reload()
			@loadMainWindow(@mainView)

		open: (options) ->
			@identifier = options.id
			@type = "channel"

			@mainView = "chat"

			swipy.rightSidebarVC.sidebarDelegate = @
			
			collection = swipy.slackCollections.channels

			@currentList = collection.findWhere({name: @identifier})
			console.log @currentList, @identifier
			swipy.topbarVC.setMainTitleAndEnableProgress(@currentList.get("name"),false)
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
		

		createTask: ( title, options ) ->
			options = {} if !options
			options.projectLocalId = @identifier if !options.projectLocalId?
			options.ownerId = @currentProject.get("ownerId")
			@taskCollectionSubset?.child.createTask(title, options)
			Backbone.trigger("reload/taskhandler")

		### 
			TaskHandler delegate
		###
		taskHandlerSortAndGroupCollection: (taskHandler, collection) ->
			self = @
			taskGroups = [{leftTitle: "PROJECT TASKS" , tasks: collection.models}]
			return taskGroups


		### 
			Get A TaskListViewController that filtered for this project
		###
		getTaskListVC: ->
			taskListVC = new TaskListViewController()
			taskListVC.addTaskCard.addDelegate = @
			taskListVC.taskHandler.listSortAttribute = "projectOrder"
			taskListVC.taskHandler.delegate = @

			# https://github.com/anthonyshort/backbone.collectionsubset
			projectId = @identifer
			@taskCollectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					return task.get("projectLocalId") is projectId and !task.get("completionDate") and !task.isSubtask()
			})
			taskListVC.taskHandler.loadCollection(@taskCollectionSubset.child)
			@taskListVC = taskListVC
			return taskListVC


		### 
			Get A ChatListViewController that filtered for this project
		###
		getChatListVC: ->
			projectId = @identifer
			@currentList.fetchMessages()
			chatListVC = new ChatListViewController()
			chatListVC.newMessage.addDelegate = @
			chatListVC.chatList.delegate = @
			chatListVC.chatList.lastRead = parseInt(@currentList.get("last_read"))
			chatListVC.chatHandler.loadCollection(@currentList.get("messages"))
			chatListVC.newMessage.setPlaceHolder("Send message to " + @currentList.get("name"))
			@chatListVC = chatListVC
			return chatListVC
		
		###
			ChatList ChatDelegate
		###
		chatListMarkAsRead: (chatList, timestamp) ->
			Backbone.trigger("mark-read", "project-"+@projectId, timestamp)
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
			options.projectLocalId = @projectId
			options.ownerId = @currentProject.get("ownerId")
			@chatCollectionSubset?.child.sendMessage(message, options)
			@chatListVC.chatList.scrollToBottomVar = true
			Backbone.trigger("reload/chathandler")
		###
			AddTaskCard Delegate
		###
		taskCardDidCreateTask: ( taskCard, title, options) ->
			@createTask( title, options)

		destroy: ->
			@chatListVC?.destroy()
			@taskListVC?.destroy()
			Backbone.off(null,null, @)
			@vc?.destroy()