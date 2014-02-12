define ["view/list/BaseTask", "jquery-hammerjs"], (BaseTaskView) ->
	BaseTaskView.extend
		bindEvents: ->
			@$el.hammer().on( "tap", ".todo-content", @toggleSelected )
			@$el.hammer().on( "tap", ".priority", @togglePriority )
			@$el.hammer().on( "doubletap", ".todo-content", @edit )
			@$el.hammer().on( "tap", ".action", @handleAction )
		afterRender: ->
			classNameMap = {
				"icon-schedule-act": "icon-clock-alt"
				"icon-todo-act": "icon-todo"
				"icon-checkmark-act": "icon-checkmark-alt"
			}

			for key, val of classNameMap
				oldEl = @$el.find ".#{key}"
				if oldEl.length then oldEl.removeClass( key ).addClass val