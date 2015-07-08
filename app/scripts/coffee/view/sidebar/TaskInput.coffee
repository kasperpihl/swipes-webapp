define ["underscore", "text!templates/sidemenu/sidemenu-add.html"], (_, AddTmpl) ->
	Backbone.View.extend
		className: "add-sidemenu"
		events:
			"submit": "triggerAddTask"
			"keyup textarea": "saveText"
			"focus textarea": "focusTextArea"
			"click .priority": "togglePriority"
		initialize: ->
			@oldTaskText = ""
			@oldTaskText = localStorage.getItem("addText") if localStorage.getItem("addText")
			@template = _.template AddTmpl
			@render()
			_.bindAll(@, "keyUpHandling", "focusTextArea")
			
		render: ->
			@$el.html @template {oldTaskText: @oldTaskText}
		togglePriority: (e) ->
			$('.add-new').toggleClass("is-priority")
		saveText: (e) ->
			localStorage.setItem("addText",$(e.currentTarget).val())
		focusTextArea: (e) ->
			val = $(e.currentTarget).val()
			$(e.currentTarget).val("").val(val)
		keyDownHandling: (e) ->
			if e.keyCode is 13
				e.preventDefault()
				if (e.metaKey or e.ctrlKey) and !(e.metaKey and e.ctrlKey)
					@triggerAddTask(e, true)
		keyUpHandling: (e) ->
			if e.keyCode is 13
				@triggerAddTask(e)
			if e.keyCode is 27
				swipy.sidebar.popView()
		triggerAddTask: (e, openTask) ->
			e.preventDefault()
			console.log "trigger"
			return if @$el.find(".add-task-field").val() is ""
			Backbone.trigger( "create-task", @$el.find(".add-task-field").val(), {open: openTask} )
			@$el.find(".add-task-field").val ""
			localStorage.setItem("addText", "")
			
		destroy: ->
			@remove()
		remove: ->
			@$el.remove()