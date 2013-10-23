define ["underscore", "backbone", "text!templates/edit-task.html", "view/editor/TagEditor"], (_, Backbone, TaskTmpl, TagEditor) ->
	Backbone.View.extend
		tagName: "article"
		className: "task-editor"
		events:
			"click .cancel": "back"
			"click .save": "save"
		initialize: ->
			@$el.addClass @model.getState()
			@setTemplate()
			@render()
		setTemplate: ->
			@template = _.template TaskTmpl
		createTagEditor: ->
			@tagEditor = new TagEditor { el: @$el.find(".icon-tags"), model: @model }
		render: ->
			@$el.html @template @model.toJSON()
			@createTagEditor()
			return @el
		back: ->
			if swipy.router.history.length > 1
				prevRoute = swipy.router.history[ swipy.router.history.length - 2 ]
				swipy.router.navigate( prevRoute, yes )
			else
				location.hash = ""
		save: ->
			atts = { title: @getTitle(), notes: @getNotes() }

			console.log "Saving ", atts

			opts = {
				success: => @back()
				error: -> swipy.errors.throw "Something went wrong. Please try again in a little bit.", arguments
			}

			@model.save( atts, opts )
		transitionInComplete: ->
			console.log "Edit view finished transitionIn"
		getTitle: ->
			@$el.find( ".title input" ).val()
		getNotes: ->
			@$el.find( ".notes textarea" ).val()