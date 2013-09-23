define ["underscore", "backbone", "text!templates/task.html"], (_, Backbone, TaskTmpl) ->
	Backbone.View.extend
		tagName: "li"
		initialize: ->
			_.bindAll( @, "onSelected" )
			
			@model.on( "change:selected", @onSelected )
			
			@setTemplate()	
			@init()
			@content = @$el.find('.todo-content')
			@render()
		setTemplate: ->
			@template = _.template TaskTmpl
		init: ->
			# Hook for views extending me
		onSelected: (model, selected) ->
			@$el.toggleClass( "selected", selected )

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