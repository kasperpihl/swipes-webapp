define [
	"underscore"
	"gsap"
	"text!templates/viewcontroller/project-view-controller.html"
	], (_, TweenLite, Template) ->
	Backbone.View.extend
		initialize: ->
			@setTemplate()
			@render()
		setTemplate: ->
			@template = _.template Template
		render: ->
			$("#main").html(@template({}))
		
		open: (options) ->
			projectId = options.id
			@loadProject(projectId)
		loadProject: (projectId) ->
			
		destroy: ->