define [
	"underscore"
	"gsap"
	"text!templates/viewcontroller/project-view-controller.html"
	"js/view/tasklist/TaskList"
	], (_, TweenLite, Template, TaskList) ->
	Backbone.View.extend
		initialize: ->
			@setTemplate()
			@render()
		setTemplate: ->
			@template = _.template Template
		render: ->
			@taskList = new TaskList()
			@taskList.dataSource = @
			@taskList.enableDragAndDrop = true
			@taskList.delegate = @
			@taskList.reload()
			#$("#main").html(@template({}))
		open: (options) ->
			projectId = options.id
			@loadProject(projectId)
		loadProject: (projectId) ->
			
		destroy: ->

		# TaskList Datasource method to ask for tasks
		tasksForTaskList: ( taskList ) ->
			return [
				{ title: "Design mockup", id:"akrn3" }
				{ title: "Test Android version", id: "algs" }
				{ title: "Prepare pitchdeck", id:"llkfs" }
				{ title: "Pack luggage for vacation", id:"fdid" }
				{ title: "Check non-fiction books for reading", id:"peie" }
				{ title: "Develop smart drag-n-drop", id:"psjwo" }
			]
		# TaskList Datasource method to ask for grouped tasks (section headers)
		groupedTasksForTaskList: ( taskList ) ->