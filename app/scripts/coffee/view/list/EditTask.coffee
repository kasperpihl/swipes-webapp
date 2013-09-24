define ["underscore", "backbone", "text!templates/edit-task.html"], (_, Backbone, TaskTmpl) ->
	Backbone.View.extend
		tagName: "article"
		className: "task-editor"
		initialize: ->
			@model.on( "change", @render, @ )
			@setTemplate()	
			@render()
		setTemplate: ->
			@template = _.template TaskTmpl
		render: ->
			# If template isnt set yet, just return the empty element
			return @el if !@template?
			
			@$el.html @template @model.toJSON()

			return @el
		remove: ->
			@cleanUp()
		customCleanUp: ->
			# Hook for views extending me
		cleanUp: ->
			@model.off()
			@customCleanUp()