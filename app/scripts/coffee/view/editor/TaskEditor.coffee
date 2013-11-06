define ["underscore", "backbone", "text!templates/task-editor.html", "view/editor/TagEditor"], (_, Backbone, TaskEditorTmpl, TagEditor) ->
	Backbone.View.extend
		tagName: "article"
		className: "task-editor"
		events:
			"click .save": "save"
			"click time": "reschedule"
		initialize: ->
			$("body").addClass "edit-mode"
			@$el.addClass @model.getState()
			@setTemplate()
			@render()
		setTemplate: ->
			@template = _.template TaskEditorTmpl
		createTagEditor: ->
			@tagEditor = new TagEditor { el: @$el.find(".icon-tags"), model: @model }
		render: ->
			@$el.html @template @model.toJSON()
			@createTagEditor()
			return @el
		save: ->
			atts = { title: @getTitle(), notes: @getNotes() }

			console.log "Saving ", atts

			opts = {
				success: => swipy.router.back()
				error: -> swipy.errors.throw "Something went wrong. Please try again in a little bit.", arguments
			}

			@model.save( atts, opts )
		reschedule: ->
			console.log "Reschedule ", @model
		transitionInComplete: ->

		getTitle: ->
			@$el.find( ".title input" ).val()
		getNotes: ->
			@$el.find( ".notes textarea" ).val()
		remove: ->
			$("body").removeClass "edit-mode"
			@undelegateEvents()
			@stopListening()
			@$el.remove()
