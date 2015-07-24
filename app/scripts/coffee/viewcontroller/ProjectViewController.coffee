define [
	"underscore"
	"gsap"
	"js/viewcontroller/TaskListViewController"
	"js/viewcontroller/ChatListViewController"
	"js/view/modal/AssignModal"
	], (_, TweenLite, TaskListViewController, ChatListViewController, AssignModal) ->
	Backbone.View.extend
		className: "project-view-controller"
		initialize: ->
			console.log "init project"
			Backbone.on("show-assign", @didPressAssign, @)
		render: (el) ->
			@$el.html ""
			$("#main").html(@$el)
			
			swipy.rightSidebarVC.reload()
			@loadMainWindow(@mainView)

		open: (options) ->
			@projectId = options.id
			@mainView = "task"

			swipy.rightSidebarVC.sidebarDelegate = @
			
			@currentProject = swipy.collections.projects.get(@projectId)
			swipy.topbarVC.setMainTitleAndEnableProgress(@currentProject.get("name"),false)
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
			chatListVC.newMessage.setPlaceHolder("Send message to " + @currentProject.get("name"))
			return chatListVC
		didPressAssign: (model, e) ->
			assignModal = new AssignModal({model: model})
			assignModal.dataSource = @
			console.log "modal"
			assignModal.render()
			swipy.modalVC.presentView(assignModal.el, {frame:true, left: e.clientX, top:e.clientY+10, centerY: false })
			
		assignModalPeopleToAssign: (assignModal) ->
			peopleToAssign = []
			model = assignModal.model
			me = swipy.collections.members.getMe()
			if me? and !model.userIsAssigned(me.id)
				peopleToAssign.push(me.toJSON())
				
			swipy.collections.members.each( (member) =>
				return if member.get("me")
				if !model.userIsAssigned(member.id)
					peopleToAssign.push(member.toJSON())
			)

			return peopleToAssign
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
			Backbone.off(null,null, @)
			@vc?.destroy()