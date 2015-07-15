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
			@name = switch memberId
				when "842" then "mitko"
				when "234" then "stanimir"
				when "324" then "stefan"
				when "123" then "yana"
				else "no name"
			swipy.topbarVC.setMainTitleAndEnableProgress(@name, false)
			@addTaskCard.setPlaceHolder("Send task to " + @name)

			@collectionSubset = new Backbone.CollectionSubset({
				parent: swipy.collections.todos,
				filter: (task) ->
					return task.get("projectId") is "3vfL9qvLxMNzv" and !task.isSubtask()
			})

			@taskHandler.loadCollection(@collectionSubset.child)
			@taskList.render()
		taskHandlerSortAndGroupCollection: (taskHandler, collection) ->
			groups = collection.groupBy((model, i) ->
				# TODO: Seperate tasks between who it's from
				if i % 2 is 0
					return "My Tasks"
				else 
					return "Your Tasks"
			)
			return [{leftTitle: "YOUR TASKS FROM " + @name.toUpperCase() , tasks: groups["Your Tasks"]},{rightTitle: @name.toUpperCase() + "'S TASKS FROM YOU", tasks: groups["My Tasks"]}]
		destroy: ->

		###
			AddTaskCard Delegate
		###
		taskCardDidCreateTask: ( taskCard, title, options) ->
			options = {} if !options
			options.projectId = @projectId
			Backbone.trigger("create-task", title, options)
			@taskList.render()