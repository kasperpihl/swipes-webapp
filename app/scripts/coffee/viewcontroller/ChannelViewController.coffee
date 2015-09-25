define [
	"underscore"
	"gsap"
	"js/viewcontroller/TaskListViewController"
	"js/viewcontroller/ChatListViewController"
	
	], (_, TweenLite, TaskListViewController, ChatListViewController) ->
	Backbone.View.extend
		className: "channel-view-controller main-view-controller"
		initialize: ->
			Backbone.on( "create-task", @createTask, @ )
		render: (el) ->
			@$el.html "<div style=\"text-align:center; margin-top:100px;\">Loading</div>"
			$("#main").html(@$el)
			
			swipy.rightSidebarVC.reload()
			setTimeout( => 
				@loadMainWindow(@mainView)
			, 5)

		open: (type, options) ->
			@identifier = options.id
			@type = type

			@mainView = "chat"

			swipy.rightSidebarVC.sidebarDelegate = @
			console.log type
			if @type isnt "im"
				collection = swipy.slackCollections.channels

				@currentList = collection.findWhere({name: @identifier})
				name = "# "+@currentList.get("name")
			else
				collection = swipy.slackCollections.channels
			
				@currentUser = swipy.slackCollections.users.findWhere({name: @identifier})
				
				@currentList = collection.findWhere({is_im: true, user: @currentUser.id})
				name = @currentUser.get("name")
				name = "slackbot & s.o.f.i." if name is "slackbot"
				
			swipy.topbarVC.setMainTitleAndEnableProgress(name, false)
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
			options.targetUserId = @currentUser.id if @currentUser?
			options.projectLocalId = @currentList.id
			@taskCollectionSubset?.child.createTask(title, options)
			Backbone.trigger("reload/taskhandler")

		### 
			TaskHandler delegate
		###
		taskHandlerSortAndGroupCollection: (taskHandler, collection, toggleCompleted) ->
			self = @
			title = @currentList.get("name")+ " tasks"

			if @currentUser?
				title =  "You & " + @currentUser.get("name") + "'s tasks"
				if @currentUser.get("name") is "slackbot"
					title = "You, slackbot & s.o.f.i's tasks"

			tasks = _.filter collection.models, (m) ->
				if toggleCompleted
					m.get("completionDate")
				else
					!m.get("completionDate")
					
			taskGroups = [{leftTitle: title , tasks: tasks}]

			return taskGroups


		### 
			Get A TaskListViewController that filtered for this project
		###
		getTaskListVC: ->
			# https://github.com/anthonyshort/backbone.collectionsubset
			projectId = @currentList.id
			@taskCollectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					return task.get("projectLocalId") is projectId and !task.isSubtask()
			})

			@taskListVC = new TaskListViewController
				delegate: @
				collectionToLoad: @taskCollectionSubset.child

		### 
			Get A ChatListViewController that filtered for this project
		###
		getChatListVC: ->
			chatListVC = new ChatListViewController()
			chatListVC.newMessage.addDelegate = @
			chatListVC.chatList.delegate = @
			chatListVC.chatList.lastRead = parseInt(@currentList.get("last_read"))
			chatListVC.chatHandler.loadCollection(@currentList)
			if @currentUser? # if is IM
				chatListVC.newMessage.setPlaceHolder("Send a message to " + @currentUser.get("name"))
				if @currentUser.get("name") is "slackbot"
					chatListVC.newMessage.setPlaceHolder("Send a message to slackbot & s.o.f.i.")
			else
				chatListVC.newMessage.setPlaceHolder("Send a message to " + @currentList.get("name"))
			@chatListVC = chatListVC

			@currentList.fetchMessages(null, (res, error) ->
				if res and res.ok
					chatListVC.chatList.hasMore = true
					chatListVC.chatList.hasRendered = false
			)
			return chatListVC
		
		###
			ChatList ChatDelegate
		###
		chatListDidScrollToTop: (chatList) ->
			return if @isFetchingMore
			@isFetchingMore = true
			@currentList.fetchOlderMessages((res, error) =>
				@isFetchingMore = false
				if res and res.ok
					if res.messages and res.messages.length
						lastMessage = res.messages[0]
						chatList.setScrollToMessage(lastMessage.ts)
			)
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