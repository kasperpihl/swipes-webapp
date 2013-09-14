define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		tagName: "li"
		initialize: ->
			_.bindAll( @, "handleSelected" )
			
			@model.on( "change:selected", @handleSelected )
			
			@setTemplate().then =>		
				@init()
				@content = @$el.find('.todo-content')
				@render()
		setTemplate: ->
			dfd = new $.Deferred()
			require ["text!templates/list-item.html"], (ListItemTmpl) =>
				@template = _.template ListItemTmpl
				dfd.resolve()
			return dfd.promise()
		init: ->
			# Hook for views extending me
		handleSelected: (model, selected) ->
			console.log "BaseListItem selected changed to: ", selected
			@$el.toggleClass( "selected", selected )
		render: ->
			# If template isnt set yet, just return the empty element
			return @el if !@template?
			
			@$el.html @template @model.toJSON()

			return @el
		remove: ->
			@cleanUp()
		cleanUp: ->
			@model.off()