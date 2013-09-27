define ["underscore", "backbone", "text!templates/task.html"], (_, Backbone, TaskTmpl) ->
	Backbone.View.extend
		tagName: "li"
		initialize: ->
			_.bindAll( @, "onSelected", "setBounds" )
			
			@listenTo( @model, "change:selected", @onSelected )
			$(window).on "resize", @setBounds

			@setTemplate()	
			@init()
			@render()
		
		setTemplate: ->
			@template = _.template TaskTmpl

		setBounds: ->
			@bounds = @el.getClientRects()[0]
		
		init: ->
			# Hook for views extending me
		
		onSelected: (model, selected) ->
			currentlySelected = @model.get( "selected" ) or false
			@model.set( "selected", !currentlySelected )
		
		edit: ->
			swipy.router.navigate( "edit/#{ @model.cid }", yes )
		
		render: ->
			# If template isnt set yet, just return the empty element
			return @el if !@template?
			
			@$el.html @template @model.toJSON()

			return @el
		
		remove: ->
			@cleanUp()
			@$el.remove()
		
		customCleanUp: ->
			# Hook for views extending me
		
		cleanUp: ->
			$(window).off()
			@undelegateEvents()
			@stopListening()
			@customCleanUp()