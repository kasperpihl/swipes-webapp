define [
	"underscore"
	"gsap"
	"js/viewcontroller/TaskListViewController"
	], (_, TweenLite, TaskListViewController) ->
	Backbone.View.extend
		className: "team-member-view-controller"
		initialize: ->
			@taskListVC = new TaskListViewController()
			@taskListVC.addTaskCard.addDelegate = @
			@taskListVC.taskList.enableDragAndDrop = true
			@taskListVC.taskHandler.listSortAttribute = "projectOrder"
			@taskListVC.taskHandler.delegate = @

		render: ->
			$("#main").html(@$el)
			@$el.html @taskListVC.el
			@taskListVC.render()
		
		open: (options) ->
			memberId = options.id
			@render()
			@loadMember(memberId)
		loadMember: (memberId) ->
			# Load team member view
			@currentMember = swipy.collections.members.get(memberId)
			swipy.topbarVC.setMainTitleAndEnableProgress(@currentMember.get("username"), false)
			@taskListVC.addTaskCard.setPlaceHolder("Send task to " + @currentMember.get("username"))

			@collectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					if !task.get("completionDate") and !task.isSubtask()
						if (task.get("userId") is Parse.User.current().id and task.get("toUserId") is memberId) or (task.get("userId") is memberId and task.get("toUserId") is Parse.User.current().id)
							return true
					return false
			})

			@taskListVC.taskHandler.loadCollection(@collectionSubset.child)
			@taskListVC.taskList.render()
		taskHandlerSortAndGroupCollection: (taskHandler, collection) ->
			self = @
			groups = collection.groupBy((model, i) ->
				# TODO: Seperate tasks between who it's from
				console.log model.get("toUserId"), self.currentMember.id
				if model.get("toUserId") is self.currentMember.id
					return "His Tasks"
				else 
					return "My Tasks"
			)
			taskGroups = []
			taskGroups.push({leftTitle: "RECEIVED TASKS" , tasks: groups["My Tasks"]}) if groups["My Tasks"]?.length > 0
			taskGroups.push({rightTitle: "SENT TASKS", tasks: groups["His Tasks"]}) if groups["His Tasks"]?.length > 0
			
			return taskGroups
		destroy: ->

		###
			AddTaskCard Delegate
		###
		taskCardDidCreateTask: ( taskCard, title, options) ->
			options = {} if !options
			options.toUserId = @currentMember.id
			options.ownerId = @currentMember.get("organisationId")
			Backbone.trigger("create-task", title, options)
			@taskListVC.taskList.render()