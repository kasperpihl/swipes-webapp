define ["underscore"
		"text!templates/tasklist/add-task-card.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		className: "add-task-card-container"
		initialize: ->
			@template = _.template Tmpl
		events:
			"keyup input": "saveTask"
		render: ->
			if !@targetSelector?
				throw new Error("TaskList must have targetSelector to render")
			@$el.html @template({})
			$(@targetSelector).html(@$el)
		saveTask: (e) ->
			if e.keyCode is 13
				@triggerAddTask(e)
		triggerAddTask: (e, openTask) ->
			e.preventDefault()
			return if @$el.find("input").val() is ""
			options = {}
			options.open = openTask if openTask
			if @delegate? and _.isFunction(@delegate.taskCardDidCreateTask)
				@delegate.taskCardDidCreateTask( @, @$el.find("input").val(), options)
			else
				throw new Error("AddTaskCard must have a delegate that implements taskCardDidCreateTask")
			@$el.find("input").val ""
