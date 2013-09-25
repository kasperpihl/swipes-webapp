define ["underscore", "backbone", "text!templates/edit-task.html"], (_, Backbone, TaskTmpl) ->
	Backbone.View.extend
		tagName: "article"
		className: "task-editor"
		events: 
			"click .cancel": "back"
			"click .save": "save"
		initialize: ->
			@model.on( "change", @render, @ )
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
			@saveTitle()
			@saveSchedule()
			@saveRepeat()
			@saveTags()
			@saveNotes()

			# @back()
		saveTitle: ->
			console.log "Saving title"
		saveSchedule: ->
			console.log "Saving schedule"
		saveRepeat: ->
			console.log "Saving repeat option"
		saveTags: ->
			console.log "Saving tags"
		saveNotes: ->
			console.log "Saving notes"
		remove: ->
			@cleanUp()
			@$el.remove()
		cleanUp: ->
			@model.off()
			@undelegateEvents()