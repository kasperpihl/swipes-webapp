define ["view/list/BaseListItem"], (BaseListItemView) ->
	BaseListItemView.extend
		events: 
			"click": "toggleSelected"
		toggleSelected: ->
			currentlySelected = @model.get( "selected" ) or false
			@model.set( "selected", !currentlySelected )
		

