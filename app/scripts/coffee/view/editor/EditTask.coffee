define ["underscore", "backbone", "text!templates/edit-task.html"], (_, Backbone, TaskTmpl) ->
	Backbone.View.extend
		tagName: "article"
		className: "task-editor"
		events: 
			"click .cancel": "back"
			"click .save": "save"
		initialize: ->
			@setTemplate()	
			@render()
		setTemplate: ->
			@template = _.template TaskTmpl
		render: ->
			# If template isnt set yet, just return the empty element
			return @el if !@template?
			
			@$el.html @template @model.toJSON()

			return @el
		back: ->
			swipy.router.navigate( "todo", yes )
		save: ->
			atts = {
				title: @getTitle()
				notes: @getNotes()
			}

			opts = {
				success: =>
					@back()
				error: (e) =>
					console.warn "Error saving ", arguments
					alert "Something went wrong. Please try again in a little bit."
			}

			@model.save( atts, opts )
		getTitle: ->
			@$el.find( ".title" )[0].innerText
		getNotes: ->
			@$el.find( ".notes p" )[0].innerText
		remove: ->
			@cleanUp()
			@$el.remove()
		cleanUp: ->
			@model.off()
			@undelegateEvents()