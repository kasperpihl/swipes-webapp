define [
	"underscore"
	"gsap"
	"js/viewcontroller/TaskListViewController"
	"js/viewcontroller/ChatListViewController"
	], (_, TweenLite, TaskListViewController, ChatListViewController) ->
	Backbone.View.extend
		className: "project-view-controller"
		initialize: ->
			

		render: (el) ->
			@$el.html ""
			$("#main").html(@$el)
			
		open: (options) ->
			@projectId = options.id
			swipy.rightSidebarVC.setNewDelegate(@)
			@loadProject(@projectId)
		loadProject: (projectId) ->
			@render()
			@currentProject = swipy.collections.projects.get(projectId)
			swipy.topbarVC.setMainTitleAndEnableProgress(@currentProject.get("name"),false)

			
			@loadMainWindow("task")
			
			
		loadMainWindow: (type) ->
			if type is "task"
				vc = @getTaskListVC()
			else if type is "chat"
				vc = @getChatListVC()
			else return
			@$el.html vc.el
			vc.render()

		### 
			Get A TaskListViewController that filtered for this project
		###
		getTaskListVC: ->
			taskListVC = new TaskListViewController()
			taskListVC.addTaskCard.addDelegate = @
			taskListVC.taskList.enableDragAndDrop = true
			taskListVC.taskHandler.listSortAttribute = "projectOrder"

			# https://github.com/anthonyshort/backbone.collectionsubset
			projectId = @projectId
			@collectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					return task.get("projectLocalId") is projectId and !task.get("completionDate") and !task.isSubtask()
			})
			taskListVC.taskHandler.loadCollection(@collectionSubset.child)
			
			return taskListVC


		### 
			Get A ChatListViewController that filtered for this project
		###
		getChatListVC: ->
			projectId = @projectId
			@collectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.messages,
				filter: (message) ->
					return message.get("projectLocalId") is projectId
			})
			chatListVC = new ChatListViewController()
			chatListVC.newMessage.addDelegate = @
			chatListVC.chatHandler.loadCollection(@collectionSubset.child)

			return chatListVC


		###
			RightSidebarDelegate
		###
		sidebarGetChatViewController: (sidebar) ->
			@getChatListVC()
		###
			NewMessage Delegate
		###
		newMessageSent: ( newMessage, message ) ->
			options = {}
			options.projectLocalId = @projectId
			options.ownerId = @currentProject.get("ownerId")
			Backbone.trigger("send-message", message, options)
			Backbone.trigger("reload/chathandler")
		###
			AddTaskCard Delegate
		###
		taskCardDidCreateTask: ( taskCard, title, options) ->
			options = {} if !options
			options.projectLocalId = @projectId
			options.ownerId = @currentProject.get("ownerId")
			Backbone.trigger("create-task", title, options)
			Backbone.trigger("reload/taskhandler")

		destroy: ->