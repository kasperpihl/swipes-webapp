define ["underscore", "text!templates/sidemenu/sidemenu-add.html"], (_, AddTmpl) ->
	Backbone.View.extend
		className: "add-sidemenu"
		events:
			"submit": "triggerAddTask"
			"keyup textarea": "saveText"
			"click .priority": "togglePriority"
		initialize: ->
			@oldTaskText = ""
			@oldTaskText = localStorage.getItem("addText") if localStorage.getItem("addText")
			@template = _.template AddTmpl
			@render()
			swipy.shortcuts.pushDelegate(@)
		render: ->
			@$el.html @template {oldTaskText: @oldTaskText}
		togglePriority: (e) ->
			$('.add-new').toggleClass("is-priority")
		saveText: (e) ->
			localStorage.setItem("addText",$(e.currentTarget).val())
		keyUpHandling: (e) ->
			if e.keyCode is 13
				@triggerAddTask(e)
				localStorage.setItem("addText", "")
			if e.keyCode is 27
				@$el.find(".add-task-field").blur()
		triggerAddTask: (e) ->
			e.preventDefault()
			return if @$el.find(".add-task-field").val() is ""

			Backbone.trigger( "create-task", @$el.find(".add-task-field").val() )
			@$el.find(".add-task-field").val ""
		destroy: ->
			@remove()
		remove: ->
			@$el.remove()
			swipy.shortcuts.popDelegate()