define ["underscore", "text!templates/task-editor.html", "text!templates/action-steps-template.html" , "js/model/TaskSortModel" ,  "js/view/editor/TagEditor", "gsap-scroll", "gsap"], (_, TaskEditorTmpl, ActionStepsTmpl, TaskSortModel, TagEditor) ->
	Backbone.View.extend
		tagName: "article"
		className: "task-editor"
		events:
			"click .go-back": "back"
			"click .priority": "togglePriority"
			"click time": "reschedule"
			"click .repeat-picker a": "setRepeat"
			"blur .input-title": "updateTitle"
			"blur .notes .input-note": "updateNotes"
			"click .repeat-button": "clickedRepeat"

			"click .step .action": "clickedAction"
			"mouseenter .step": "trackMouse"
			"mouseleave .step": "stopTrackingMouse"
		trackMouse: (e) ->
			@isHovering = true
			@bouncedHover($(e.currentTarget))
		stopTrackingMouse: (e) ->
			@isHovering = false
			@onUnhoverTask( $(e.currentTarget) )
		onHoverTask: (target) ->
			if @isHovering
				target.addClass "delete-hover"
		onUnhoverTask: (target) ->
			target.removeClass "delete-hover"
				
		initialize: ->
			$("body").addClass "edit-mode"
			@setTemplate()
			@bouncedHover = _.debounce(@onHoverTask, 1500)
			@sorter = new TaskSortModel()
			_.bindAll( @, "clickedAction", 'updateActionStep', "keyUpHandling", "trackMouse", "stopTrackingMouse", "back" )
			@render()
			@listenTo( @model, "change:schedule change:repeatOption change:priority change:title change:subtasksLocal", @render )
			@backRoute = "list/todo"
			if @model.get("state") is "scheduled"
				@backRoute = "list/scheduled"
			else if @model.get("state") is "completed"
				@backRoute = "list/completed"
		setTemplate: ->
			@template = _.template TaskEditorTmpl
		killTagEditor: ->
			if @tagEditor?
				@tagEditor.cleanUp()
				@tagEditor.remove()
		createTagEditor: ->
			@tagEditor = new TagEditor { el: @$el.find(".icon-tag-container"), model: @model }
		setStateClass: ->
			@$el.removeClass("active scheduled completed").addClass @model.getState()

		render: ->
			renderedContent = @model.toJSON()
			if renderedContent.notes and renderedContent.notes.length > 0
				renderedContent.notes = renderedContent.notes.replace(/(?:\r\n|\r|\n)/g, '<br>')
				renderedContent.notes = renderedContent.notes.replace(/ /g,"&nbsp;")
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
			renderedContent.title = renderedContent.title.replace(/ /g , "&nbsp;")
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
			else 
				$( @el ).find( "#current-steps-container" ).html("")
			$( @el ).find( ".divider h2" ).html( titleString )
		back: ->
			if @backRoute?
				swipy.router.navigate(@backRoute, true)
			else 
				swipy.router.back()
			return false
		reschedule: ->
			Backbone.trigger( "show-scheduler", [@model] )
		transitionInComplete: ->
			swipy.shortcuts.setDelegate( @ )
		keyDownHandling: (e) ->
			if e.keyCode is 32 and !$("input").is(":focus") and !$("div.content-editable").is(':focus') 
				e.preventDefault()
			if e.keyCode is 13 and $('.input-title').is(':focus')
				e.preventDefault()
		keyUpHandling: (e) ->
			if e.keyCode is 13
				if($('.action-steps .step input:focus').length is 1)
					@updateActionStep(null, $('.action-steps .step input:focus'))
					e.preventDefault()
				else if $('.input-title').is(':focus')
					$('.input-title').blur()
					e.preventDefault()

				
			if e.keyCode is 32 and !$("input").is(":focus") and !$("div.content-editable").is(':focus') 
				$(".add-step input").focus()
				TweenLite.set( $("#scrollcont"), { scrollTo: 0 } )
				e.preventDefault()
			if e.keyCode is 27
				if $(".add-step input").is(":focus")
					$(".add-step input").val("")
					$(".add-step input").blur()
				else if($('.action-steps .step input:focus').length is 1)
					$('.action-steps .step input:focus').val("")
					@updateActionStep(null, $('.action-steps .step input:focus'))
				else if $(".task-editor input").is(":focus")
					$(".task-editor input").blur()
				else if $('.input-note').is(':focus')
					$('.input-note').blur()
				else @back()
		clickedRepeat: ->
			$(".repeat-picker > ul").toggleClass("active")
		togglePriority: ->
			@model.togglePriority()
		setRepeat: (e) ->
			@model.setRepeatOption $(e.currentTarget).data "option"
		updateTitle: ->
			@model.updateTitle @getTitle()

		updateNotes: ->
			notes = @getNotes()
			if notes != @model.get "notes"
				@model.updateNotes notes
				swipy.analytics.sendEvent("Tasks", "Notes", "", notes.length )
				swipy.analytics.sendEventToIntercom("Update Note", { "Length": notes.length })
				@render()
		updateActionStep: (e, target) ->
			if e and !target
				target = $(e.currentTarget)
			title = target.val()
			title = title.trim()
			model = @getModelFromEl(target)
			if title.length is 0
				if model?
					target.val(model.get("title"))
				target.blur()
				return false
			if title.length > 255
				title = title.substr(0,255)
			
			if model?
				model.updateTitle title
				target.blur()
			else
				@model.addNewSubtask( title, "Input" )
				target.val("")
				target.focus()
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
			action = "delete" if target.hasClass("delete")
			if action is "complete"
				model.completeTask()
				swipy.analytics.sendEvent( "Action Steps", "Completed" )
				swipy.analytics.sendEventToIntercom( "Completed Action Step" )
			else if action is "delete"
				if confirm "Delete action step?"
					model.deleteObj()
					@renderSubtasks()
			else
				model.scheduleTask( null )
			@renderSubtasks()
		getTitle: ->
			@$el.find( ".input-title" ).html().replace(/&nbsp;/g , " ")
		getNotes: ->
			$noteField = @$el.find('.notes .input-note')
			replacedBrs = $noteField.html()
			#console.log "1"+replacedBrs

			expression = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/g
			regex = new RegExp(expression)

			while m = regex.exec(replacedBrs)
				#console.log index
				index = m.index
				url = m[0]
				input = m.input
				brStartIndex = index + url.length
				nextText = input.substring( brStartIndex )
				if nextText? and nextText.length > 3
						if nextText.indexOf("<br>") is 0
							continue
				replacedBrs = [replacedBrs.slice(0, brStartIndex), "<br>", replacedBrs.slice(brStartIndex)].join('');
			#console.log "2"+replacedBrs

			replacedBrs = replacedBrs.replace(/<div><br>/g , "<div1>\r\n")
			#console.log "3"+replacedBrs
			replacedBrs = replacedBrs.replace(/<br>/g , "\r\n")
			#console.log "4"+replacedBrs
			replacedBrs = replacedBrs.replace(/<div>/g, "\r\n")
			#console.log "5"+replacedBrs
			replacedBrs = replacedBrs.replace(/&nbsp;/g , " ")
			#console.log "6"+replacedBrs
			replacedBrs = replacedBrs.replace(/<(?:.|\n)*?>/gm, '')
			#console.log "7"+replacedBrs
			#replacedBrs = replacedBrs.replace(/INS/g, "\r\n")
			
			replacedBrs
		remove: ->
			$("body").removeClass "edit-mode"
			@undelegateEvents()
			@stopListening()
			@$el.remove()
