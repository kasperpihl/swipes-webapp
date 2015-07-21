define [
	"underscore"
	"gsap"
	"text!templates/viewcontroller/my-tasks-view-controller.html"
	"js/view/tasklist/TaskList"
	"js/view/tasklist/AddTaskCard"
	"js/handler/TaskHandler"
	], (_, TweenLite, Template, TaskList, AddTaskCard, TaskHandler) ->
	Backbone.View.extend
		className: "my-tasks-view-controller"
		initialize: ->
			@setTemplate()

			@addTaskCard = new AddTaskCard()
			@addTaskCard.addDelegate = @

			@taskList = new TaskList()
			@taskList.targetSelector = ".my-tasks-view-controller .task-list-container"
			@taskList.enableDragAndDrop = true
			@taskList.delegate = @

			@taskHandler = new TaskHandler()
			@taskHandler.listSortAttribute = "order"

			
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
			@render()
			@load()
		load: ->
			
			swipy.topbarVC.setMainTitleAndEnableProgress("My Tasks", false )
			@addTaskCard.setPlaceHolder("Add Personal Task")
			# https://github.com/anthonyshort/backbone.collectionsubset
			@collectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					if !task.get("completionDate") and !task.isSubtask()
						if task.get("toUserId") is Parse.User.current().id or task.get("isAssignedToMe")
							return true
					return false
			})
			console.log @collectionSubset.child
			@taskHandler.loadCollection(@collectionSubset.child)
			@taskList.render()
		destroy: ->

		###
			AddTaskCard Delegate
		###
		taskCardDidCreateTask: ( taskCard, title, options) ->
			options = {} if !options
			options.toUserId = Parse.User.current().id
			Backbone.trigger("create-task", title, options)
			@taskList.render()