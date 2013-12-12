define ["underscore", "backbone", "view/list/TagEditorOverlay"], (_, Backbone, TagEditorOverlay) ->
	Parse.View.extend
		el: ".action-bar"
		events:
			"click .edit": "editTask"
			"click .tags": "editTags"
			"click .delete": "deleteTasks"
			"click .share": "shareTasks"
		initialize: ->
			@hide()
			@listenTo( swipy.todos, "change:selected", @toggle )
		toggle: ->
			selectedTasks = swipy.todos.filter (m) -> m.get "selected"
			if @shown
				if selectedTasks.length is 0
					@hide()
			else
				if selectedTasks.length > 0
					@show()
		show: ->
			@$el.toggleClass( "fadeout", no )
			@shown = yes

		hide: ->
			@$el.toggleClass( "fadeout", yes )
			@shown = no
		kill: ->
			@stopListening()
			@hide()
		editTask: ->
			target = swipy.todos.filter( (m) -> m.get "selected" )[0].id
			swipy.router.navigate( "edit/#{ target }", yes )
		editTags: ->
			@tagEditor = new TagEditorOverlay( models: swipy.todos.filter (m) -> m.get "selected" )
		deleteTasks: ->
			selectedTasks = swipy.todos.filter (m) -> m.get "selected"
			return unless selectedTasks.length
			if confirm "Delete #{selectedTasks.length} tasks?"
				for model in selectedTasks
					if model.has "order"
						order = model.get "order"
						model.unset "order"
						swipy.todos.bumpOrder( "up", order )

					model.save( "deleted", yes )
				@hide()
		shareTasks: ->
			selectedTasks = swipy.todos.filter (m) -> m.get "selected"
			return unless selectedTasks.length

			console.log "Sharing ", selectedTasks
