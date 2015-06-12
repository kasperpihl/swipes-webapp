define ["underscore"
		"text!templates/task-editor.html"
		"text!templates/task-editor-content.html" 
		"text!templates/action-steps-template.html" 
		"js/model/TaskSortModel"
		"js/view/list/ActionBar"
		"gsap-scroll"
		"gsap"
	], (_, TaskEditorTmpl, TaskEditorContentTmpl, ActionStepsTmpl, TaskSortModel, ActionBar) ->
	Backbone.View.extend
		tagName: "article"
		className: "task-editor"
		events:
			"click .go-back": "back"
			"click .priority": "togglePriority"
			"click .schedule-label": "reschedule"
			"click .repeat-picker a": "setRepeat"
			"click .icon-tag-container" : "clickTags"
			"blur .input-title": "updateTitle"
			"blur .notes .input-note": "updateNotes"
			"focus .notes .input-note": "focusNotes"
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
			@$el.html @template( { priority: @model.get("priority") } )
			@bouncedHover = _.debounce(@onHoverTask, 1500)
			@sorter = new TaskSortModel()
			
			_.bindAll( @, "clickedAction", 'updateActionStep', "keyUpHandling", "trackMouse", "stopTrackingMouse", "back" )
			@render()
			@listenTo( @model, "change:schedule change:repeatOption change:priority change:title change:subtasksLocal", @render )
			@listenTo( @model, "change:deleted",@back)
			@listenTo( @model, "change:tags", @renderTags)
			@listenTo( Backbone, "complete-task", @completeTask )
			@listenTo( Backbone, "todo-task", @markTaskAsTodo )
			@listenTo( Backbone, "schedule-task", @scheduleTask )
			@backRoute = "list/todo"
			if @model.get("state") is "scheduled"
				@backRoute = "list/scheduled"
			else if @model.get("state") is "completed"
				@backRoute = "list/completed"

			state = "tasks"
			state = "done" if @model.get("state") is "completed"
			state = "schedule" if @model.get("state") is "scheduled"
			self = @
			setTimeout(
				->
					self.actionbar = new ActionBar({el: '.edit-action-bar', state: state, noCounter:true, noTags: true, delegate: self})
					self.model.set("selected",true)
					self.actionbar.show()
			, 3)
			
		setTemplate: ->
			@template = _.template TaskEditorTmpl
			@contentTemplate = _.template TaskEditorContentTmpl
		setStateClass: ->
			@$el.removeClass("active scheduled completed").addClass @model.getState()
		render: (first) ->
			
			state = "tasks"
			state = "done" if @model.get("state") is "completed"
			state = "schedule" if @model.get("state") is "scheduled"
			@actionbar?.handleButtonsFromState(state)
			renderedContent = @model.toJSON()
			renderedContent.title = renderedContent.title.replace(/ /g , "&nbsp;")
			#renderedContent.title = @replaceURLsWithHTML(renderedContent.title)
			@$el.find(".editor-content").html @contentTemplate renderedContent
			@renderSubtasks()
			@renderTags()
			@renderNotes()
			@setStateClass()
			return @el


# Handling Notes
		focusNotes: (e) ->
			return if e.target.className is "link-reference"
			if @emptyNotes? and @emptyNotes
				@$el.find(".editor-content .input-note").html("")
			@$el.find('.link').each( (i, e) ->
				obj = $(e)
				linkVal = obj.find("a").html() + "<br>"
				obj.before(linkVal)
				obj.remove()
			)
		renderNotes: ->
			notes = @model.get("notes")
			if notes and notes.length > 0
				notes = notes.replace(/(?:\r\n|\r|\n)/g, '<br>')
				notes = notes.replace(/ /g," &nbsp;")
				notes = @replaceURLsWithHTML(notes, "addDiv", "addBr")
				notes = notes.replace(/ &nbsp;/g,"&nbsp;")
				@emptyNotes = false
			else
				notes = "Add Notes"
				@emptyNotes = true
			@$el.find(".editor-content .input-note").html(notes)
		updateNotes: ->
			notes = @getNotesFromHtml()
			if notes != @model.get "notes"
				@model.updateNotes notes
				swipy.analytics.sendEvent("Tasks", "Notes", "", notes.length )
				swipy.analytics.sendEventToIntercom("Update Note", { "Length": notes.length })
			@renderNotes()
		replaceURLsWithHTML: (text, addDiv, addBr)->
			finalString = text
			if text and text.length > 0
				expression = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/g
				regex = new RegExp(expression)
				tempString = text
				foundURLs = []
				counter = 0
				while m = regex.exec(tempString)
					counter++
					index = m.index
					url = m[0]
					input = m.input
					#console.log "before:" + finalString
					finalString = finalString.replace(url+" &nbsp;", url)
					finalString = finalString.replace(url+"<br>", url)
					#console.log "after: " + finalString
					# Check whether next line is new line / if so remove it as it will be rendered like that automatically
					brStartIndex = index + url.length
					nextText = input.substring( brStartIndex )

					if foundURLs.indexOf(url) is -1
						replacement = "<a href=\""+ url + "\" target=\"_blank\" class=\"link-reference\" contentEditable=\"false\">" + url + "</a>"
						if addDiv
							replacement = "<div contentEditable=\"false\" class=\"link\">" + replacement + "</div>"
						finalString = finalString.replace(url, replacement)
						foundURLs.push url
			finalString
		getNotesFromHtml: ->
			$noteField = @$el.find('.notes .input-note')
			replacedBrs = $noteField.html()
			counter = 0
			if replacedBrs is "<br>"
				return ""
			#console.log(++counter + replacedBrs)
			replacedBrs = replacedBrs.replace(/<div><br><\/div>/g , "<div1>\r\n")
			#console.log(++counter + replacedBrs)

			replacedBrs = replacedBrs.replace(/<div>/g, "\r\n")
			#console.log(++counter + replacedBrs)
			replacedBrs = replacedBrs.replace(/<br>/g , "\r\n")
			#console.log(++counter + replacedBrs)

			replacedBrs = replacedBrs.replace(/&nbsp;/g , " ")
			#console.log(++counter + replacedBrs)
			replacedBrs = replacedBrs.replace(/<(?:.|\n)*?>/gm, '')
			#console.log(++counter + replacedBrs)

			###expression = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/g
			regex = new RegExp(expression)

			while m = regex.exec(replacedBrs)
				#console.log index
				index = m.index
				url = m[0]
				input = m.input
				brStartIndex = index + url.length
				nextText = input.substring( brStartIndex )
				if nextText? and nextText.length > 3
						if nextText.indexOf("\r\n") is 0
							continue
				replacedBrs = [replacedBrs.slice(0, brStartIndex), "\r\n", replacedBrs.slice(brStartIndex)].join('');
			#console.log "7"+replacedBrs
			###

			replacedBrs



		renderTags: ->
			tagString = "Add tags"
			tags = @model.get "tags"
			if tags and tags.length > 0
				tagString = _.invoke(tags, "get", "title").join(", ")
			@$el.find('.icon-tag-container .tag-string').html(tagString)
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
		didDeleteTasks: (i) ->
			@back()
		back: ->
			if @backRoute?
				swipy.router.navigate(@backRoute, true)
			else 
				swipy.router.back()
			return false
		clickTags: ->
			@actionbar.editTags()
		reschedule: ->
			Backbone.trigger( "show-scheduler", [@model] )
		transitionInComplete: ->
			swipy.shortcuts.setDelegate( @ )
		keyDownHandling: (e) ->
			if e.keyCode is 32 and !$(document.activeElement).is("input") and !$(document.activeElement).is("div.content-editable") #and !$("input").is(":focus") and !$("div.content-editable").is(':focus') 
				e.preventDefault()
			if e.keyCode is 13 and $('.input-title').is(':focus')
				e.preventDefault()
		keyUpHandling: (e) ->
			if e.keyCode is 13
				if $('.action-steps .step input:focus').length is 1
					@updateActionStep(null, $('.action-steps .step input:focus'))
					e.preventDefault()
				else if $('.input-title').is(':focus')
					$('.input-title').blur()
					e.preventDefault()

				
			if e.keyCode is 32 and !$(document.activeElement).is("input") and !$(document.activeElement).is("div.content-editable")
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
				else if $('.input-note').is(':focus')
					$('.input-note').blur()
				else if $('.input-title').is(':focus')
					$('.input-title').blur()
				else @back()

		completeTask: (model) ->
			tasks = swipy.todos.getSelected( model )
			return if tasks.length is 0
			for task in tasks
				task.completeTask()
			@render()
		markTaskAsTodo: (model) ->
			tasks = swipy.todos.getSelected( model )
			return if tasks.length is 0
			for task in tasks
				task.scheduleTask task.getDefaultSchedule()
			@render()
		scheduleTask: (model) ->
			tasks = swipy.todos.getSelected( model )
			return if tasks.length is 0
			Backbone.trigger( "show-scheduler", tasks )

		clickedRepeat: ->
			$(".repeat-picker > ul").toggleClass("active")
		togglePriority: ->
			@model.togglePriority()
			$(".editor-content").toggleClass("is-priority")
		setRepeat: (e) ->
			@model.setRepeatOption $(e.currentTarget).data "option"
		updateTitle: ->
			title = @validateTitle(@getTitle())
			if !title
				@$el.find( ".input-title" ).html(@model.get("title"))
				return
			@model.updateTitle title
		validateTitle: (title) ->
			title = title.trim()
			if title.length is 0
				return false
			else if title.length > 255
				title = title.substr(0,255)
			return title

		
		updateActionStep: (e, target) ->
			if e and !target
				target = $(e.currentTarget)
			model = @getModelFromEl(target)
			title = @validateTitle(target.val())

			if !title
				if model?
					target.val(model.get("title"))
				target.blur()
				return false
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
		
		remove: ->
			@model.set("selected",false)
			$("body").removeClass "edit-mode"
			@undelegateEvents()
			@stopListening()
			@$el.remove()
