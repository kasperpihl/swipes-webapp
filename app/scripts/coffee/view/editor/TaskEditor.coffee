define ["underscore", "backbone", "text!templates/task-editor.html", "text!templates/action-steps-template.html" , "js/model/TaskSortModel" ,  "js/view/editor/TagEditor", "gsap-scroll", "gsap"], (_, Backbone, TaskEditorTmpl, ActionStepsTmpl, TaskSortModel, TagEditor) ->
	Backbone.View.extend
		tagName: "article"
		className: "task-editor"
		events:
			"click .save": "save"
			"click .priority": "togglePriority"
			"click time": "reschedule"
			"click .repeat-picker a": "setRepeat"
			"blur .title input": "updateTitle"
			"blur .notes .input-note": "updateNotes"
			"change .step input": "updateActionStep"
			"click .step .action": "clickedAction"
		initialize: ->
			$("body").addClass "edit-mode"
			@setTemplate()
			@sorter = new TaskSortModel()
			_.bindAll( @, "clickedAction", 'updateActionStep', "keyUpHandling" )
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
			renderedContent = @model.toJSON()
			if renderedContent.notes and renderedContent.notes.length > 0
				renderedContent.notes = renderedContent.notes.replace(/(?:\r\n|\r|\n)/g, '<br>')
				expression = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/g
				regex = new RegExp(expression)
				tempNoteString = renderedContent.notes
				foundURLs = []
				counter = 0
				while m = regex.exec(tempNoteString)
					counter++
					index = m.index
					url = m[0]
					input = m.input
					brStartIndex = index + url.length
					nextText = input.substring( brStartIndex )
					addedNewline = false
					if nextText? and nextText.length > 3
						if nextText.indexOf("<br>") is 0
							url += "<br>"
							addedNewline = true
							tempNoteString = tempNoteString.slice(0, brStartIndex) + tempNoteString.substr(brStartIndex+4)
					if !nextText? or nextText.length < 5
						addExtraPoint = false
						addExtraPoint = true if nextText.length is 0
						addExtraPoint = true if addedNewline
						if addExtraPoint
							renderedContent.notes += "<div><br></div>"
					if foundURLs.indexOf(url) is -1
						renderedContent.notes = renderedContent.notes.replace(url, "<div contentEditable><a href=\""+ url + "\" target=\"_blank\" contentEditable=\"false\">" + url + "</a></div>")
						foundURLs.push url

			@$el.html @template renderedContent
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
					jsonedTask.cid = task.cid
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
			swipy.shortcuts.setDelegate( @ )
		keyDownHandling: (e) ->
			if e.keyCode is 32 and !$("input").is(":focus")
				e.preventDefault()
		keyUpHandling: (e) ->
			if e.keyCode is 13 and !$("input").is(":focus")
				@save()
			else if e.keyCode is 13 and $(".add-step input").val().length is 0
				$(".add-step input").blur()
			if e.keyCode is 32 and !$("input").is(":focus")
				$(".add-step input").focus()
				TweenLite.set( window, { scrollTo: 0 } )
				e.preventDefault()
			if e.keyCode is 27
				if $(".add-step input").is(":focus")
					$(".add-step input").val("")
					$(".add-step input").blur()
				else if $(".task-editor input").is(":focus")
					$(".task-editor input").blur()
				else @save()
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
				@render()
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
			model = @getModelFromEl( target )
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
			$noteField = @$el.find('.notes .input-note')
			replacedBrs = $noteField.html().replace(/<br>/g , "\r\n")
			replacedBrs = replacedBrs.replace(/<(?:.|\n)*?>/gm, '')
			replacedBrs
		remove: ->
			$("body").removeClass "edit-mode"
			@undelegateEvents()
			@stopListening()
			@$el.remove()
