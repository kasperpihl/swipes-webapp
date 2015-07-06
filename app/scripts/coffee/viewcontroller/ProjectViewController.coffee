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
			#$("#main").html(@template({}))
		
		open: (options) ->
			projectId = options.id
			@loadProject(projectId)
		loadProject: (projectId) ->
			
		destroy: ->