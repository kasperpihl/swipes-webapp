###

###
define [
	"underscore"
	"text!templates/tasklist/task.html"
	], (_, TaskTmpl) ->
	Backbone.View.extend
		tagName: "li"
		className: "task-item"
		events:
			"click .card-container": "clickedTask"
			"click .actions a": "handleAction"
		initialize: ->
			throw new Error("Model must be added when constructing a TaskCard") if !@model?
			@template = _.template TaskTmpl, {variable: "data" }
			_.bindAll( @, 'clickedTask', 'handleAction' )
			@listenTo( @model, "change:selected", @onSelected )
		clickedTask: (e) ->
			if @taskDelegate? and _.isFunction(@taskDelegate.taskDidClick)
				@taskDelegate.taskDidClick(@model, e)
		handleAction: (e) ->
			# Actual trigger logic
			if @taskDelegate? and _.isFunction(@taskDelegate.taskDidClickAction)
				@taskDelegate.taskDidClickAction(@model, e)
		render: ->
			
			@$el.attr('id', "task-"+@model.id )
			@$el.html @template( task: @model )

			return @
		onSelected: (model, selected) ->
			@$el.toggleClass( "selected", selected )
		remove: ->
			@$el.empty()