define ["view/list/BaseTask"], (BaseTaskView) ->
	BaseTaskView.extend
		bindEvents: ->
			# Bind all events manually, so events extending me can use the
			# events hash freely
			@$el.on( "tap", ".todo-content", @toggleSelected )
			# @$el.on( "dblclick", "h2", @edit )
		enableReordering: ->
			console.warn "Enabling touch gestures for reordering"
		disableReordering: ->
			console.warn "Disabling touch gestures for reordering"
		

