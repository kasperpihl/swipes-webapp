define ["underscore", "backbone", "text!templates/task-editor.html", "view/editor/TagEditor"], (_, Backbone, TaskEditorTmpl, TagEditor) ->
	Backbone.View.extend
		tagName: "article"
		className: "task-editor"
		events:
			"click .save": "save"
			"click time": "reschedule"
			"click .repeat-picker a": "setRepeat"
			"blur .title input": "updateTitle"
			"blur .notes textarea": "updateNotes"
		initialize: ->
			$("body").addClass "edit-mode"
			@$el.addClass @model.getState()
			@setTemplate()

			@render()
			@listenTo( @model, "change:schedule change:repeatOption", @render )
		setTemplate: ->
			@template = _.template TaskEditorTmpl
		killTagEditor: ->
			if @tagEditor?
				@tagEditor.cleanUp()
				@tagEditor.remove()
		createTagEditor: ->
			@tagEditor = new TagEditor { el: @$el.find(".icon-tags"), model: @model }
		render: ->
			@$el.html @template @model.toJSON()
			@killTagEditor()
			@createTagEditor()
			return @el
		save: ->
			opts = {
				success: => swipy.router.back()
				error: -> swipy.errors.throw "Something went wrong. Please try again in a little bit.", arguments
			}

			@model.save( {}, opts )
		reschedule: ->
			Backbone.trigger( "show-scheduler", [@model] )
		transitionInComplete: ->

		setRepeat: (e) ->
			@model.set( "repeatOption", $(e.currentTarget).data "option" )
		updateTitle: ->
			@model.set( "title", @getTitle() )
		updateNotes: ->
			@model.set( "notes", @getNotes() )
		getTitle: ->
			@$el.find( ".title input" ).val()
		getNotes: ->
			@$el.find( ".notes textarea" ).val()
		remove: ->
			$("body").removeClass "edit-mode"
			@undelegateEvents()
			@stopListening()
			@$el.remove()
