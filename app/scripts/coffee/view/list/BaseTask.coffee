define ["underscore", "backbone", "text!templates/task.html"], (_, Backbone, TaskTmpl) ->
	Backbone.View.extend
		tagName: "li"
		initialize: ->
			_.bindAll( @, "onSelected", "setBounds", "toggleSelected", "edit" )
			
			@listenTo( @model, "change:selected", @onSelected )
			$(window).on "resize", @setBounds

			@setTemplate()	
			@init()
			@render()

			@$el.on( "click", ".todo-content", @toggleSelected )
			@$el.on( "dblclick", "h2", @edit )
		
		setTemplate: ->
			@template = _.template TaskTmpl

		setBounds: ->
			@bounds = @el.getClientRects()[0]
		
		init: ->
			# Hook for views extending me
		
		toggleSelected: ->
			currentlySelected = @model.get( "selected" ) or false
			@model.set( "selected", !currentlySelected )

		onSelected: (model, selected) ->
			@$el.toggleClass( "selected", selected )
		
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
			@$el.off()
			@undelegateEvents()
			@stopListening()
			@customCleanUp()