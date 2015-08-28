define ["underscore"
		"text!templates/tasklist/tabs/add-action-row.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		className: "add-action-container action-item"
		initialize: ->
			@placeHolder = "Add new action"
			@template = _.template Tmpl, { variable: "data" }
			@render()
		events:
			"keyup input": "saveTask"
		render: ->
			@$el.html @template({ placeHolder: @placeHolder})
			@delegateEvents()
			return @
		setPlaceHolder: (placeholder) ->
			@placeHolder = placeholder
			@$el.find('input').attr('placeholder',placeholder)
		saveTask: (e) ->
			if e.keyCode is 13
				@triggerAddTask(e)
		triggerAddTask: (e) ->
			e.preventDefault()
			return if @$el.find("input").val() is ""
			options = {}
			if @addDelegate? and _.isFunction(@addDelegate.actionRowDidCreateAction)
				@addDelegate.actionRowDidCreateAction( @, @$el.find("input").val(), options)
			else
				throw new Error("AddTaskCard must have an addDelegate that implements taskCardDidCreateTask")
			@$el.find("input").val ""
		remove: ->
			@destroy()
			@$el.empty()
		destroy: ->
			@undelegateEvents()