define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		initialize: ->
			_.bindAll( @, "handleSelected" )
			
			@content = @$el.find('.todo-content')
			
			@model.on( "change:selected", @handleSelected )
			
			@render()
		handleSelected: (model, selected) ->
			@$el.toggleClass( "selected", selected )
		render: ->
			return @el
		remove: ->
			@cleanUp()
		cleanUp: ->
			@model.off()