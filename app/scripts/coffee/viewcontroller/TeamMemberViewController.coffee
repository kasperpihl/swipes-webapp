define [
	"underscore"
	"gsap"
	"text!templates/viewcontroller/team-member-view-controller.html"
	"js/view/tasklist/TaskList"
	"js/view/tasklist/AddTaskCard"
	"js/handler/TaskHandler"
	], (_, TweenLite, Template, TaskList, AddTaskCard, TaskHandler) ->
	Backbone.View.extend
		className: "team-member-view-controller"
		initialize: ->
			@setTemplate()
			
			@addTaskCard = new AddTaskCard()
			@addTaskCard.addDelegate = @


			@taskList = new TaskList()
			@taskList.targetSelector = ".team-member-view-controller .task-list-container"
			@taskList.enableDragAndDrop = true
			@taskList.delegate = @


			@taskHandler = new TaskHandler()
			@taskHandler.listSortAttribute = "projectOrder"
			@taskHandler.delegate = @

			
			# Settings the Task Handler to receive actions from the task list
			@taskList.taskDelegate = @taskHandler
			@taskList.dragDelegate = @taskHandler
			@taskList.dataSource = @taskHandler

		setTemplate: ->
			@template = _.template Template
		render: ->
			@$el.html @template({})
			$("#main").html(@$el)

			@addTaskCard.render()
			@$el.find('.task-column').prepend( @addTaskCard.el )
		
		open: (options) ->
			memberId = options.id
			@render()
			@loadMember(memberId)
		loadMember: (memberId) ->
			# Load team member view
			@currentMember = swipy.collections.members.get(memberId)
			swipy.topbarVC.setMainTitleAndEnableProgress(@currentMember.get("username"), false)
			@addTaskCard.setPlaceHolder("Send task to " + @currentMember.get("username"))

			@collectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					if (task.get("userId") is Parse.User.current().id and task.get("toUserId") is memberId) or (task.get("userId") is memberId and task.get("toUserId") is Parse.User.current().id)
						return true
					return false
			})

			@taskHandler.loadCollection(@collectionSubset.child)
			@taskList.render()
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
			return [{leftTitle: "YOUR TASKS FROM " + @currentMember.get("username").toUpperCase() , tasks: groups["My Tasks"]},{rightTitle: @currentMember.get("username").toUpperCase() + "'S TASKS FROM YOU", tasks: groups["His Tasks"]}]
		destroy: ->

		###
			AddTaskCard Delegate
		###
		taskCardDidCreateTask: ( taskCard, title, options) ->
			options = {} if !options
			options.toUserId = @currentMember.id
			options.ownerId = @currentMember.get("organisationId")
			Backbone.trigger("create-task", title, options)
			@taskList.render()