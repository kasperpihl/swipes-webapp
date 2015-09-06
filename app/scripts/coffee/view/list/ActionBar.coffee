define ["underscore", "js/view/overlay/TagEditorOverlay"], (_, TagEditorOverlay) ->
	Backbone.View.extend
		el: ".action-bar"
		tagName: ".action-bar"
		events:
			"click .tags": "editTags"
			"click .delete": "deleteTasks"
			"click .share": "shareTasks"
			"click .action-snooze": "snoozeTasks"
			"click .action-today": "todayTasks"
			"click .action-complete": "completeTasks"
		constructor: ( obj ) ->
			if obj && obj.el
				@el = obj.el
				@tagName = obj.el
			Backbone.View.apply @, arguments
		initialize: (obj)->
			if obj.state
				@state = obj.state
			if obj.noCounter
				@noCounter = true
			if obj.noTags
				@noTags = true
			if obj.delegate
				@delegate = obj.delegate

			@hide()
			self = @
			setTimeout(
				->
					self.handleButtonsFromState()
			, 500)
			@handleButtonsFromState(obj.state)
			@listenTo( swipy.collections.todos, "change:selected", @toggle )
		handleButtonsFromState:(state) ->
			if state
				@state = state
			showComplete = true if @state isnt "done"
			showSchedule = true #if state isnt "schedule"
			showTasks = true if @state isnt "tasks"
			$(@tagName + ' .snooze, ' + @tagName + ' .today, ' + @tagName + ' .complete').hide()
			$(@tagName + ' .snooze').show() if showSchedule
			$(@tagName + ' .today').show() if showTasks
			$(@tagName + ' .complete').show() if showComplete

			$(@tagName + ' .tags').hide()
			$(@tagName + ' .tags').show() unless @noTags?


		toggle: ->
			return @hide() if $("body").hasClass("organise")
			selectedTasks = swipy.collections.todos.filter (m) -> m.get "selected"
			if !@noCounter? and !@noCounter
				if selectedTasks.length < 1
					$(@tagName  + ' .counting-selected').hide()
				else
					$(@tagName  + ' .counting-selected').show()
					$(@tagName  + ' .counting-selected .selected-labe').html(""+selectedTasks.length)
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
			@tagEditor = new TagEditorOverlay( models: swipy.collections.todos.filter (m) -> m.get "selected" )
		deleteTasks: ->
			selectedTasks = swipy.collections.todos.filter (m) -> m.get "selected"
			return unless selectedTasks.length
			if confirm "Delete #{selectedTasks.length} tasks?"
				for model in selectedTasks
					model.deleteObj()
				@hide()
				return if !@delegate?
				if _.isFunction(@delegate.didDeleteTasks)
					@delegate.didDeleteTasks(selectedTasks.length)
		shareTasks: ->
			selectedTasks = swipy.collections.todos.filter (m) -> m.get "selected"
			return unless selectedTasks.length

			# Set up email subject and start body
			emailString = "mailto:?subject="+ encodeURIComponent("Tasks to complete") + "&body="
			# Add title
			emailString += encodeURIComponent "Tasks: \r\n"
			for task in selectedTasks
				emailString += encodeURIComponent "◯ " + task.get( "title" ) + "\r\n"
				for subtask in task.uncompletedSubtasks()
					addedSubtask = true
					emailString += encodeURIComponent "   ◯ " + subtask.get( "title" ) + "\r\n"
				if addedSubtask
					emailString += "\r\n"
					addedSubtask = false
			

			# Add footer
			emailString += encodeURIComponent "\r\nCreated with Swipes – Task list made for High Achievers\r\nhttp://swipesapp.com"

			location.href = emailString