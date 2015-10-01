###

###
define [
	"underscore"
	"text!templates/tasklist/edit-task.html"
	"js/view/tasklist/tabs/ActionTab"
	"js/view/modal/GenericModal"
	], (_, EditTaskTmpl, ActionTab, GenericModal) ->
	Backbone.View.extend
		className: "edit-task"
		events:
			"click .nav-item": "clickedNav"
			"click .go-back": "back"
			"blur .input-title": "updateTitle"
			"keyup .input-title": "keyUpTitle"
			"keydown .input-title": "keyDownTitle"
			"click .assignees-list .assignee": "clickedAssignee"
			"click #assign-text-button": "clickedAssign"
			"click .open-schedule": "clickedSchedule"
			"click .assign-task": "clickedAssign"
			"click .delete-task": "deleteTask"
			"click .comlete-task": "completeTask"

		initialize: ->
			throw new Error("Model must be added when constructing EditTask") if !@model?
			@template = _.template EditTaskTmpl, {variable: "data" }
			@bouncedRender = _.debounce(@render, 5)
			@model.on("change:assignees change:schedule", @bouncedRender, @ )
		render: ->
			@$el.html @template( task: @model )
			setTimeout( =>
				@loadActionSteps()
				if @? and (!@model.get("assignees") or @model.get("assignees").length is 0)
					@$el.find(".assign-label").removeClass("hidden")
					setTimeout( => 
						if @? and @$el
							@$el.find(".assign-label").addClass("hideAnimate")
					, 4000)
			,0)

			return @


		back: ->
			if @delegate? and _.isFunction(@delegate.editTaskDidClickBack)
				@delegate.editTaskDidClickBack(@)
			#swipy.router.back({trigger:false})
			false

		keyUpTitle: (e) ->
			if e.keyCode is 13 and ($('.input-title').is(':focus') or $('.input-title *').is(':focus'))
				$('.input-title').blur()
				window.getSelection().removeAllRanges()
				e.preventDefault()
		keyDownTitle: (e) ->
			if e.keyCode is 13 and ($('.input-title').is(':focus') or $('.input-title *').is(':focus'))
				e.preventDefault()

		###
			Schedule Handling / Rendering
		###
		clickedSchedule: (e) ->
			Backbone.trigger( "show-scheduler", @model, e )


		###
			Asssign Handling / Rendering
		###
		clickedAssignee: (e) ->
			userId = $(e.currentTarget).attr("data-href")
			console.log userId
			@model.unassign(userId, true)
		clickedAssign: (e) ->
			Backbone.trigger("show-assign", @model, e)
			false

		###
			Title Handling / Rendering etc
		###
		updateTitle: ->
			title = @validateTitle(@getTitle())

			if !title
				@$el.find( ".input-title" ).html(@model.get("title"))
				return

			@model.updateTitle title
			Backbone.trigger("reload/taskhandler")
		getTitle: ->
			@$el.find( ".input-title" ).html().replace(/&nbsp;/g , " ")
		validateTitle: (title) ->
			title = title.trim()
			if title.length is 0
				return false
			else if title.length > 255
				title = title.substr(0,255)
			return title


		###
			Action Steps handling / Rendering
		###
		loadActionSteps: ->
			@actionTab = new ActionTab({model: @model})
			@$el.find(".action-step-container").html @actionTab.el
			@actionTab.loadActionSteps()

		completeTask: ->
			self = @

			if self.delegate? && _.isFunction(self.delegate.taskHandler.taskCardDidComplete)
				#T_TODO put a nice animation for completing here
				#@animateWithClass("fadeOutRight").then ->
				self.delegate.taskHandler.taskCardDidComplete(self)
				self.back()

		deleteTask: ->
			self = @

			deleteCallback = ((self) ->
				return () ->
					if self.delegate? && _.isFunction(self.delegate.taskHandler.taskCardDoDelete)
						#T_TODO put a nice animation for deleting here
						#self.animateWithClass("fadeOutLeft").then ->
						self.delegate.taskHandler.taskCardDoDelete(self)
						self.back()
			)(self)

			genericModal = new GenericModal
				type: 'deleteModal'
				submitCallback: deleteCallback
				tmplOptions:
					title: 'Delete task'
					cancelText: 'NO'
					submitText: 'YES'
					text: "Are you sure you want to delete this task? You can't undo that action!"
			false
		remove: ->
			@actionTab?.remove()
			@$el.empty()
