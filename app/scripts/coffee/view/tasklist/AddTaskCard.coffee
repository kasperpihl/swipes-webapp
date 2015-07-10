define ["underscore"
		"text!templates/tasklist/add-task-card.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		className: "add-task-card-container task-item"
		initialize: ->
			@template = _.template Tmpl
			@render()
		events:
			"keyup input": "saveTask"
		render: ->
			@$el.html @template({})
			@delegateEvents()
			return @
		saveTask: (e) ->
			if e.keyCode is 13
				@triggerAddTask(e)
		triggerAddTask: (e, openTask) ->
			e.preventDefault()
			return if @$el.find("input").val() is ""
			options = {}
			options.open = openTask if openTask
			if @addDelegate? and _.isFunction(@addDelegate.taskCardDidCreateTask)
				@addDelegate.taskCardDidCreateTask( @, @$el.find("input").val(), options)
			else
				throw new Error("AddTaskCard must have an addDelegate that implements taskCardDidCreateTask")
			@$el.find("input").val ""
		remove: ->
			console.log "remove"
		destroy: ->
			console.log "destroyed"
			@undelegateEvents()