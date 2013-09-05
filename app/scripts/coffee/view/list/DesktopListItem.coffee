define ["view/list/BaseListItem"], (BaseListItemView) ->
	BaseListItemView.extend
		enableInteraction: ->
			console.log "Enabling interaction for desktop"
		disableInteraction: ->
			console.warn "Disabling interaction for desktop for ", @model.toJSON()

