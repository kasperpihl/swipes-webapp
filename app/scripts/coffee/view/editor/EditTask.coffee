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
			
			@createTagEditor()
		setTemplate: ->
			@template = _.template TaskTmpl
		createTagEditor: ->
			@tagEditor = new TagEditor { el: @$el.find(".icon-tags"), model: @model }
		render: ->
			@$el.html @template @model.toJSON()
			return @el
		back: ->
			history.back()
		save: ->
			atts = {
				title: @getTitle()
				notes: @getNotes()
			}

			console.log "Saving ", atts

			opts = {
				success: =>
					@back()
				error: =>
					console.warn "Error saving ", arguments
					alert "Something went wrong. Please try again in a little bit."
			}

			@model.save( atts, opts )
		getTitle: ->
			@$el.find( ".title input" ).val()
		getNotes: ->
			@$el.find( ".notes textarea" ).val()
		remove: ->
			@cleanUp()
			@$el.remove()
		cleanUp: ->
			@model.off()
			@undelegateEvents()