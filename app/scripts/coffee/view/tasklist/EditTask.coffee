###

###
define [
	"underscore"
	"text!templates/tasklist/edit-task.html"
	"js/view/tasklist/tabs/ActionTab"
	], (_, EditTaskTmpl, ActionTab) ->
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
			"click .schedule-container": "clickedSchedule"

		initialize: ->
			throw new Error("Model must be added when constructing EditTask") if !@model?
			@template = _.template EditTaskTmpl, {variable: "data" }
			@bouncedRender = _.debounce(@render, 5)
			@model.on("change:assignees change:schedule", @bouncedRender, @ )
		render: ->
			@$el.html @template( task: @model )
			setTimeout( =>
				@loadActionSteps()
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



		remove: ->
			@actionTab?.remove()
			@$el.empty()