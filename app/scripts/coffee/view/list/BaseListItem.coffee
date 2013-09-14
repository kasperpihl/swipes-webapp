define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		initialize: ->
			_.bindAll( @, "handleSelected" )
			
			@init()

			@content = @$el.find('.todo-content')
			@model.on( "change:selected", @handleSelected )
			
			@render()
		init: ->
			# Hook for views extending me
		handleSelected: (model, selected) ->
			@$el.toggleClass( "selected", selected )
		render: ->
			return @el
		remove: ->
			@cleanUp()
		cleanUp: ->
			@model.off()