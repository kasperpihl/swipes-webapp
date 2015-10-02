###

###
define [
	"underscore"
	"text!templates/tasklist/tabs/action-row.html"
	], (_, ActionTmpl) ->
	Backbone.View.extend
		tagName: "li"
		className: "action-item"
		events:
			"blur .input-action-title": "updateTitle"
			"keyup .input-action-title": "keyUpTitle"
			"keydown .input-action-title": "keyDownTitle"
			"click .action-step-buttons div": "handleAction"
		initialize: ->
			throw new Error("Model must be added when constructing an ActionRow") if !@model?
			@template = _.template ActionTmpl, {variable: "data" }
			@bouncedRender = _.debounce(@render, 5)
		keyUpTitle: (e) ->
			if e.keyCode is 13 and ($('.input-action-title').is(':focus') or $('.input-action-title *').is(':focus'))
				@$el.find('.input-action-title').blur()
				window.getSelection().removeAllRanges()
				e.preventDefault()
		keyDownTitle: (e) ->
			if e.keyCode is 13 and ($('.input-action-title').is(':focus') or $('.input-action-title *').is(':focus'))
				e.preventDefault()
		updateTitle: ->
			title = @validateTitle(@getTitle())
			@$el.find(".input-action-title").attr("contentEditable", false)
			if !title
				@$el.find( ".input-action-title" ).html(@model.get("title"))
				return

			@model.updateTitle title
		getTitle: ->
			@$el.find( ".input-action-title" ).html().replace(/&nbsp;/g , " ")
		validateTitle: (title) ->
			title = title.trim()
			if title.length is 0
				return false
			else if title.length > 255
				title = title.substr(0,255)
			return title
		handleAction: (e) ->
			# Actual trigger logic
			return false if !@taskDelegate?

			self = @
			currentTarget = $(e.currentTarget)

			if currentTarget.hasClass("complete") and _.isFunction(@taskDelegate.taskActionStepComplete)
				#@animateWithClass("fadeOutRight").then ->
				#self.$el.hide()
				self.taskDelegate.taskActionStepComplete(self, @taskDelegate.delegate.model) # we pass here the parent task's model
			false
		render: ->
			@$el.attr('id', "task-"+@model.id )
			@$el.html @template( task: @model )

			return @
		remove: ->
			@$el.empty()
