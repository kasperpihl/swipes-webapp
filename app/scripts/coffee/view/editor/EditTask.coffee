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
				schedule: @getSchedule()
				repeatDate: @getRepeatDate()
				tags: @getTags()
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
			# @back()
		getTitle: ->
			@$el.find( ".title" )[0].innerText
		getSchedule: ->
			console.log "Saving schedule"
		getRepeatDate: ->
			console.log "Saving repeat option"
		getTags: ->
			console.log "Saving tags"
		getNotes: ->
			console.log "Saving notes"
		remove: ->
			@cleanUp()
			@$el.remove()
		cleanUp: ->
			@model.off()
			@undelegateEvents()