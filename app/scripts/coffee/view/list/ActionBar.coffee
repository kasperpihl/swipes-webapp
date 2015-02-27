define ["underscore", "js/view/list/TagEditorOverlay"], (_, TagEditorOverlay) ->
	Backbone.View.extend
		el: ".action-bar"
		events:
			"click .tags": "editTags"
			"click .delete": "deleteTasks"
			"click .share": "shareTasks"
			"click .action-snooze": "snoozeTasks"
			"click .action-today": "todayTasks"
			"click .action-complete": "completeTasks"

		initialize: (obj)->
			
			@hide()
			self = @
			setTimeout(
				->
					self.handleButtonsFromState(obj.state)
			, 500)
			#@handleButtonsFromState(obj.state)
			
			
			@listenTo( swipy.todos, "change:selected", @toggle )
		handleButtonsFromState:(state) ->
			showComplete = true if state isnt "done"
			showSchedule = true if state isnt "schedule"
			showTasks = true if state isnt "tasks"
			$('.action-bar .snooze, .action-bar .today, .action-bar .complete').hide()
			$('.action-bar .snooze').show() if showSchedule
			$('.action-bar .today').show() if showTasks
			$('.action-bar .complete').show() if showComplete


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
			$('.todo-list:not(.hidden)').addClass("selecting")
			@shown = yes
		hide: ->
			$('.todo-list').removeClass("selecting")
			@$el.toggleClass( "fadeout", yes )
			@shown = no
		kill: ->
			@undelegateEvents()
			@stopListening()
			@hide()
		snoozeTasks: ->
			Backbone.trigger( "schedule-task" )
		todayTasks: ->
			Backbone.trigger( "todo-task" )
		completeTasks: ->
			Backbone.trigger( "complete-task" )
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

					model.deleteObj()
				@hide()
				swipy.analytics.sendEvent( "Tasks", "Deleted", "", selectedTasks.length )
				swipy.analytics.sendEventToIntercom( "Deleted Tasks", { "Number of Tasks": selectedTasks.length })
		shareTasks: ->
			selectedTasks = swipy.todos.filter (m) -> m.get "selected"
			console.log selectedTasks
			return unless selectedTasks.length

			# Set up email subject and start body
			emailString = "mailto:?subject="+ encodeURIComponent("Tasks to complete") + "&body="
			# Add title
			emailString += encodeURIComponent "Tasks: \r\n"

			# Add tasks
			emailString += encodeURIComponent "◯ " + task.get( "title" ) + "\r\n" for task in selectedTasks

			# Add footer
			emailString += encodeURIComponent "\r\nSent from Swipes — http://swipesapp.com"
			console.log emailString
			location.href = emailString

			swipy.analytics.sendEvent( "Share Task", "Opened", "", selectedTasks.length )
			swipy.analytics.sendEventToIntercom( "Share Task Opened", {"Number of Tasks": selectedTasks.length })
