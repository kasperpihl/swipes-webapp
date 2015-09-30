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
		initialize: ->
			throw new Error("Model must be added when constructing an ActionRow") if !@model?
			@template = _.template ActionTmpl, {variable: "data" }
			@bouncedRender = _.debounce(@render, 5)
		keyUpTitle: (e) ->
			if e.keyCode is 13 and ($('.input-action-title').is(':focus') or $('.input-action-title *').is(':focus'))
				$('.input-action-title').blur()
				window.getSelection().removeAllRanges()
				e.preventDefault()
		keyDownTitle: (e) ->
			if e.keyCode is 13 and ($('.input-action-title').is(':focus') or $('.input-action-title *').is(':focus'))
				e.preventDefault()
		updateTitle: ->
			title = @validateTitle(@getTitle())

			if !title
				@$el.find( ".input-action-title" ).html(@model.get("title"))
				return

			@model.updateTitle title
			Backbone.trigger("reload/taskhandler")
		getTitle: ->
			@$el.find( ".input-action-title" ).html().replace(/&nbsp;/g , " ")
		validateTitle: (title) ->
			title = title.trim()
			if title.length is 0
				return false
			else if title.length > 255
				title = title.substr(0,255)
			return title
		render: ->
			@$el.attr('id', "task-"+@model.id )
			@$el.html @template( task: @model )

			return @
		remove: ->
			@$el.empty()
