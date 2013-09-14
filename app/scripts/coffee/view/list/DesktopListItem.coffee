define ["view/list/BaseListItem"], (BaseListItemView) ->
	BaseListItemView.extend
		events: 
			"click": "toggleSelected"
		toggleSelected: ->
			currentlySelected = @model.get( "selected" ) or false
			console.log "DesktopListItem change selected to ", !currentlySelected
			@model.set( "selected", !currentlySelected )
		

