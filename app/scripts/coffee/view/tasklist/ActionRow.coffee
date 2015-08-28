###

###
define [
	"underscore"
	"text!templates/tasklist/tabs/action-row.html"
	], (_, ActionTmpl) ->
	Backbone.View.extend
		tagName: "li"
		className: "action-item"
		initialize: ->
			throw new Error("Model must be added when constructing an ActionRow") if !@model?
			@template = _.template ActionTmpl, {variable: "data" }
			@bouncedRender = _.debounce(@render, 5)
		render: ->
			@$el.attr('id', "task-"+@model.id )
			@$el.html @template( task: @model )

			return @
		remove: ->
			@$el.empty()