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
			@$el.html "<div style=\"text-align:center; margin-top:100px;\">Loading</div>"
			$("#main").html(@$el)
			
			swipy.rightSidebarVC.reload()
			setTimeout( => 
				@loadMainWindow(@mainView)
			, 5)

		open: (options) ->
			@identifier = options.id
			@type = "channel"

			@mainView = "chat"

			swipy.rightSidebarVC.sidebarDelegate = @
			
			collection = swipy.slackCollections.channels

			@currentList = collection.findWhere({name: @identifier})
			swipy.topbarVC.setMainTitleAndEnableProgress("# "+@currentList.get("name"),false)
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
			options.projectLocalId = @currentList.id if !options.projectLocalId?
			@taskCollectionSubset?.child.createTask(title, options)
			Backbone.trigger("reload/taskhandler")

		### 
			TaskHandler delegate
		###
		taskHandlerSortAndGroupCollection: (taskHandler, collection) ->
			self = @
			taskGroups = [{leftTitle: @currentList.get("name")+ " tasks" , tasks: _.filter(collection.models, (m) -> !m.get("completionDate"))}]
			return taskGroups


		### 
			Get A TaskListViewController that filtered for this project
		###
		getTaskListVC: ->
			taskListVC = new TaskListViewController()
			taskListVC.addTaskCard.addDelegate = @
			taskListVC.taskHandler.listSortAttribute = "projectOrder"
			taskListVC.taskHandler.delegate = @
			isGroup = @currentList.get("is_group")
			channelLabel = if isGroup then "group" else "channel"
			hashLabel = if isGroup then "" else "# "
			taskListVC.taskList.emptyTitle = "No tasks in " + hashLabel + @currentList.get("name")
			taskListVC.taskList.emptySubtitle = "You can add new tasks below or simply drag a message here."
			taskListVC.taskList.emptyDescription = "When you add tasks in this "+channelLabel+", they will be visible only to its members. You can assign tasks to them and they'll be sent to your teammates' personal workspaces."
			
			taskListVC.addTaskCard.setPlaceHolder("Add a new task to #" + @currentList.get("name"))
			# https://github.com/anthonyshort/backbone.collectionsubset
			projectId = @currentList.id
			@taskCollectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					return task.get("projectLocalId") is projectId and !task.isSubtask()
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
			chatListVC.chatHandler.loadCollection(@currentList)
			chatListVC.newMessage.setPlaceHolder("Send a message to " + @currentList.get("name"))
			@chatListVC = chatListVC
			return chatListVC
		
		###
			ChatList ChatDelegate
		###
		chatListMarkAsRead: (chatList, timestamp) ->
			@currentList.markAsRead()
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
			swipy.slackSync.sendMessage( message, @currentList.id)
			@chatListVC.chatList.scrollToBottomVar = true
			@chatListVC.chatList.removeUnreadIfSeen = true
		newFileSelected: (newMessage, file) ->
			newMessage.setUploading(true)
			swipy.slackSync.uploadFile(@currentList.id, file, (res, error) ->
				newMessage.setUploading(false)
				if res and res.ok
					console.log "success!"
				else
					alert("An error happened with the upload")
			)
		newMessageIsTyping: (newMessage ) ->
			options = {type: "typing", channel: @currentList.id }
			swipy.slackSync.doSocketSend(options, true)
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