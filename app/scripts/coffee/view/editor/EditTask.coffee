define ["underscore", "backbone", "text!templates/edit-task.html", "view/editor/TagEditor"], (_, Backbone, TaskTmpl, TagEditor) ->
	Backbone.View.extend
		tagName: "article"
		className: "task-editor"
		events: 
			"click .cancel": "back"
			"click .save": "save"
		initialize: ->
			@setTemplate()
			@render()
			
			@createTagEditor()
		setTemplate: ->
			@template = _.template TaskTmpl
		createTagEditor: ->
			@tagEditor = new TagEditor { el: @$el.find(".icon-tags"), model: @model }
		render: ->
			# If template isnt set yet, just return the empty element
			return @el if !@template?
			
			@$el.html @template @model.toJSON()

			return @el
		back: ->
			history.back()
		save: ->
			atts = {
				title: @getTitle()
				notes: @getNotes()
			}

			opts = {
				success: =>
					@back()
				error: =>
					console.warn "Error saving ", arguments
					alert "Something went wrong. Please try again in a little bit."
			}

			@model.save( atts, opts )
		getTitle: ->
			@$el.find( ".title" ).text()
		getNotes: ->
			@$el.find( ".notes p" ).text()
		remove: ->
			@cleanUp()
			@$el.remove()
		cleanUp: ->
			@model.off()
			@undelegateEvents()