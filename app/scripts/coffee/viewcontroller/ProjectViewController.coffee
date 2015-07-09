define [
	"underscore"
	"gsap"
	"text!templates/viewcontroller/project-view-controller.html"
	"js/view/tasklist/TaskList"
	"js/view/tasklist/AddTaskCard"
	"js/handler/TaskHandler"
	], (_, TweenLite, Template, TaskList, AddTaskCard, TaskHandler) ->
	Backbone.View.extend
		initialize: ->
			@setTemplate()

			@taskList = new TaskList()
			@taskList.targetSelector = ".project-view-controller .task-list"
			@taskList.enableDragAndDrop = true
			@taskList.delegate = @

			@taskHandler = new TaskHandler()
			@taskList.dragDropDelegate = @taskHandler


			@addTask = new AddTaskCard()
			@addTask.targetSelector = ".project-view-controller .add-task"
			@addTask.delegate = @

		setTemplate: ->
			@template = _.template Template
		render: ->
			$("#main").html(@template({}))
			@addTask.render()
		open: (options) ->
			@projectId = options.id
			@render()
			@loadProject(@projectId)
		loadProject: (projectId) ->
			@taskList.dataSource = @taskHandler
			@currentProject = swipy.collections.projects.get(projectId)
			console.log @currentProject.get("name")
			swipy.topbarVC.setMainTitle(@currentProject.get("name"))
			@taskHandler.loadSubcollection(
				(task) ->
					return task.get("projectId") is projectId and !task.isSubtask()
			)
			
			@taskList.reload()
		destroy: ->

		###
			AddTaskCard Delegate
		###
		taskCardDidCreateTask: ( taskCard, title, options) ->
			options = {} if !options
			options.projectId = @projectId
			Backbone.trigger("create-task", title, options)
			@taskList.reload()