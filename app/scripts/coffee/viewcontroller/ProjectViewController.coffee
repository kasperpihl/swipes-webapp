define [
	"underscore"
	"gsap"
	"text!templates/viewcontroller/project-view-controller.html"
	"js/view/tasklist/TaskList"
	"js/view/tasklist/AddTaskCard"
	], (_, TweenLite, Template, TaskList, AddTaskCard) ->
	Backbone.View.extend
		initialize: ->
			@setTemplate()

			@taskList = new TaskList()
			@taskList.dataSource = @
			@taskList.targetSelector = ".project-view-controller .task-list"
			@taskList.enableDragAndDrop = true
			@taskList.delegate = @

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
			@projectCollection = swipy.collections.todos.subcollection(
				filter: (task) ->
					return task.get("projectId") is projectId and !task.isSubtask()
			)
			console.log @projectCollection
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
		### 
			TaskList Delegate
		###
		taskListDidHitFromDrag: ( taskList, draggedId, hit ) ->
			console.log draggedId, hit
			
		### 
			TaskList Datasource
		###
		tasksForTaskList: ( taskList ) ->
			console.log @projectCollection.toJSON()
			return @projectCollection.toJSON()