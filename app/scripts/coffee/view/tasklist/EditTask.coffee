###

###
define [
	"underscore"
	"text!templates/tasklist/edit-task.html"
	], (_, EditTaskTmpl) ->
	Backbone.View.extend
		className: "edit-task"
		events:
			"click .nav-item": "clickedNav"
		initialize: ->
			throw new Error("Model must be added when constructing EditTask") if !@model?
			@template = _.template EditTaskTmpl, {variable: "data" }
			@bouncedRender = _.debounce(@render, 5)
		render: ->
			@$el.html @template( task: @model )

			return @
		clickedNav: (e) ->
			target = $(e.currentTarget)
		remove: ->
			@$el.empty()