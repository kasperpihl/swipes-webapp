define ["underscore", "backbone", "text!templates/task-editor.html", "text!templates/action-steps-template.html" , "js/model/TaskSortModel" ,  "js/view/editor/TagEditor"], (_, Backbone, TaskEditorTmpl, ActionStepsTmpl, TaskSortModel, TagEditor) ->
	Backbone.View.extend
		tagName: "article"
		className: "task-editor"
		events:
			"click .save": "save"
			"click .priority": "togglePriority"
			"click time": "reschedule"
			"click .repeat-picker a": "setRepeat"
			"blur .title input": "updateTitle"
			"blur .notes textarea": "updateNotes"
			"change .step input": "updateActionStep"
			"click .step .action": "clickedAction"
		initialize: ->
			$("body").addClass "edit-mode"
			@setTemplate()
			@sorter = new TaskSortModel()
			_.bindAll( @, "clickedAction", 'updateActionStep' )
			@render()
			@listenTo( @model, "change:schedule change:repeatOption change:priority change:title", @render )
		setTemplate: ->
			@template = _.template TaskEditorTmpl
		killTagEditor: ->
			if @tagEditor?
				@tagEditor.cleanUp()
				@tagEditor.remove()
		createTagEditor: ->
			@tagEditor = new TagEditor { el: @$el.find(".icon-tag-bold"), model: @model }
		setStateClass: ->
			@$el.removeClass("active scheduled completed").addClass @model.getState()
		render: ->
			
			@$el.html @template @model.toJSON()
			@renderSubtasks()
			@setStateClass()
			@killTagEditor()
			@createTagEditor()
			return @el
		renderSubtasks: ->
			@subtasks = @sorter.setTodoOrder( @model.getOrderedSubtasks(), false )
			titleString = "Tasks"
			if @subtasks.length > 0
				tmplData = {}
				jsonedSubtasks = []
				completedCounter = 0
				for task in @subtasks
					if task.get("completionDate")
						completedCounter++
					jsonedTask = task.toJSON()
					jsonedTask.cid = task.cid;
					jsonedSubtasks.push(jsonedTask)
				tmplData.subtasks = jsonedSubtasks
				titleString = "" + completedCounter + " / " + jsonedSubtasks.length + " Steps"
				$( @el ).find( "#current-steps-container" ).html _.template(ActionStepsTmpl) tmplData
			$( @el ).find( ".divider h2" ).html( titleString )
		save: ->
			swipy.router.back()
		reschedule: ->
			Backbone.trigger( "show-scheduler", [@model] )
		transitionInComplete: ->
		togglePriority: ->
			@model.togglePriority()
		setRepeat: (e) ->
			@model.setRepeatOption $(e.currentTarget).data "option"
		updateTitle: ->
			@model.updateTitle @getTitle()
		updateNotes: ->
			if @getNotes() != @model.get "notes"
				@model.updateNotes @getNotes()
				swipy.analytics.sendEvent("Tasks", "Notes", "", @getNotes().length )
				swipy.analytics.sendEventToIntercom("Update Note", { "Length": @getNotes().length })

			
		updateActionStep: (e) ->
			target = $(e.currentTarget)
			title = target.val()
			title = title.trim()
			model = @getModelFromEl($(e.currentTarget))
			if title.length is 0
				if model?
					target.val(model.get("title"))
				return false
			if title.length > 255
				title = title.substr(0,255)
			
			if model?
				model.updateTitle title
			else
				@model.addNewSubtask( title, "Input" )
				target.val("")
			@renderSubtasks()
		getModelFromEl: ( el ) ->
			step = el.closest( ".step" )
			cid = step.attr("data-cid")
			for task in @subtasks
				if task.cid is cid
					foundTask = task
			foundTask
		clickedAction: (e) ->
			target = $(e.currentTarget)
			model = @getModelFromEl( target );
			action = "complete"
			action = "todo" if target.hasClass("todo")
			if action is "complete"
				model.completeTask()
				swipy.analytics.sendEvent( "Action Steps", "Completed" )
				swipy.analytics.sendEventToIntercom( "Completed Action Step" )
			else
				model.scheduleTask( null )
			@renderSubtasks()
		getTitle: ->
			@$el.find( ".title input" ).val()
		getNotes: ->
			@$el.find( ".notes textarea" ).val()
		remove: ->
			$("body").removeClass "edit-mode"
			@undelegateEvents()
			@stopListening()
			@$el.remove()
