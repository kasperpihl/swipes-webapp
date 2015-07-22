define [
	"underscore"
	"gsap"
	"text!templates/viewcontroller/project-view-controller.html"
	"js/view/tasklist/TaskList"
	"js/view/tasklist/AddTaskCard"
	"js/handler/TaskHandler"
	], (_, TweenLite, Template, TaskList, AddTaskCard, TaskHandler) ->
	Backbone.View.extend
		className: "project-view-controller"
		initialize: ->
			@setTemplate()

			@addTaskCard = new AddTaskCard()
			@addTaskCard.addDelegate = @


			@taskList = new TaskList()
			@taskList.targetSelector = ".project-view-controller .task-list-container"
			@taskList.enableDragAndDrop = true
			@taskList.delegate = @

			@taskHandler = new TaskHandler()
			@taskHandler.listSortAttribute = "projectOrder"

			
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
			@projectId = options.id
			swipy.rightSidebarVC.sidebarDelegate = @
			@render()
			@loadProject(@projectId)
		loadProject: (projectId) ->
			
			@currentProject = swipy.collections.projects.get(projectId)
			
			swipy.topbarVC.setMainTitleAndEnableProgress(@currentProject.get("name"),false)

			# https://github.com/anthonyshort/backbone.collectionsubset
			@collectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					return task.get("projectLocalId") is projectId and !task.get("completionDate") and !task.isSubtask()
			})
			
			@taskHandler.loadCollection(@collectionSubset.child)
			@taskList.render()

			#swipy.rightSidebarVC.loadWindow(@el)
		destroy: ->

		###
			RightSidebarDelegate
		###
		sidebarClickedMenuButton: (sidebar, e) ->
			

		###
			AddTaskCard Delegate
		###
		taskCardDidCreateTask: ( taskCard, title, options) ->
			options = {} if !options
			options.projectLocalId = @projectId
			options.ownerId = @currentProject.get("ownerId")
			Backbone.trigger("create-task", title, options)
			@taskList.render()