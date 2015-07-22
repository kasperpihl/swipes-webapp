define [
	"underscore"
	"text!templates/viewcontroller/task-list-view-controller.html"
	"js/view/tasklist/TaskList"
	"js/view/tasklist/AddTaskCard"
	"js/handler/TaskHandler"
	], (_, Template, TaskList, AddTaskCard, TaskHandler) ->
	Backbone.View.extend
		className: "task-list-view-controller"
		initialize: ->
			@setTemplate()

			@addTaskCard = new AddTaskCard()


			@taskList = new TaskList()
			@taskList.targetSelector = ".task-list-view-controller .task-list-container"

			@taskHandler = new TaskHandler()
			# Settings the Task Handler to receive actions from the task list
			@taskList.taskDelegate = @taskHandler
			@taskList.dragDelegate = @taskHandler
			@taskList.dataSource = @taskHandler


		setTemplate: ->
			@template = _.template Template
		render: ->
			@$el.html @template({})
			@addTaskCard.render()
			@$el.find('.task-column').prepend( @addTaskCard.el )
