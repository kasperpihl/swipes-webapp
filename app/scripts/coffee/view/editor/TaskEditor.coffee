define ["underscore", "backbone", "text!templates/task-editor.html", "view/editor/TagEditor"], (_, Backbone, TaskEditorTmpl, TagEditor) ->
	Parse.View.extend
		tagName: "article"
		className: "task-editor"
		events:
			"click .save": "save"
			"click .priority": "togglePriority"
			"click time": "reschedule"
			"click .repeat-picker a": "setRepeat"
			"blur .title input": "updateTitle"
			"blur .notes textarea": "updateNotes"
		initialize: ->
			$("body").addClass "edit-mode"
			@setTemplate()

			@render()
			@listenTo( @model, "change:schedule change:repeatOption change:priority", @render )
		setTemplate: ->
			@template = _.template TaskEditorTmpl
		killTagEditor: ->
			if @tagEditor?
				@tagEditor.cleanUp()
				@tagEditor.remove()
		createTagEditor: ->
			@tagEditor = new TagEditor { el: @$el.find(".icon-tags"), model: @model }
		setStateClass: ->
			@$el.removeClass("active scheduled completed").addClass @model.getState()
		render: ->
			@$el.html @template @model.toJSON()
			@setStateClass()
			@killTagEditor()
			@createTagEditor()
			return @el
		save: ->
			swipy.router.back()
		reschedule: ->
			Backbone.trigger( "show-scheduler", [@model] )
		transitionInComplete: ->
		togglePriority: ->
			if @model.get "priority"
				@model.save( "priority", 0 )
			else
				@model.save( "priority", 1 )
		setRepeat: (e) ->
			@model.save( "repeatOption", $(e.currentTarget).data "option" )
		updateTitle: ->
			@model.save( "title", @getTitle() )
		updateNotes: ->
			@model.save( "notes", @getNotes() )
		getTitle: ->
			@$el.find( ".title input" ).val()
		getNotes: ->
			@$el.find( ".notes textarea" ).val()
		remove: ->
			$("body").removeClass "edit-mode"
			@undelegateEvents()
			@stopListening()
			@$el.remove()
