define [
	"underscore"
	"text!templates/tasklist/task-section.html"
	"text!templates/tasklist/task.html"
	], (_, TaskSectionTmpl, TaskTmpl) ->
	Backbone.View.extend
		initialize: ->
			# Set HTML tempalte for our list
			@taskSectionTemplate = _.template TaskSectionTmpl
			@taskTemplate = _.template TaskTmpl
			@render()
		remove: ->
			@cleanUp()
			@$el.empty()
		render: ->
			tempTasks = [
				{ title: "Design mockup" }
				{ title: "Test Android version" }
			]
			$("#main").html( @taskSectionTemplate( tasks: tempTasks, taskTmpl: @taskTemplate ))
		customCleanUp: ->
		cleanUp: ->
			# A hook for the subviews to do custom clean ups
			@customCleanUp()
