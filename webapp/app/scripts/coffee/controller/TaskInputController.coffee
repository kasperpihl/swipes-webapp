define ["underscore", "js/view/TaskInput", "js/model/TagModel"], (_, TaskInputView, TagModel ) ->
	class TaskInputController
		constructor: ->
			@view = new TaskInputView()
			Backbone.on( "create-task", @createTask, @ )
		parseTags: (str) ->
			result = str.match /#(.[^,#]+)/g

			if result
				# Trim white space and remove #-character from results
				tagNameList = ( $.trim tag.replace("#", "") for tag in result )
				tags = []

				for tagName in tagNameList
					tag = swipy.tags.getTagByName tagName
					if not tag then tag = new TagModel( title: tagName )

					tags.push tag

				return tags
			else
				return []

		parseTitle: (str) ->
			if str[0] is "#" then return ""

			result = str.match(/[^#]+/)?[0]
			if result then result = $.trim result
			return result
		createTask: (str) ->
			return unless swipy.todos?

			tags = @parseTags str
			title = @parseTitle str
			order = 0
			animateIn = yes

			# If user is trying to add
			if !title
				msg = "You cannot create a todo by simply adding a tag. We need a title too. Titles should come before tags when you write out your task."
				Backbone.trigger( "throw-error", msg )
				return

			swipy.todos.bumpOrder()
			newTodo = swipy.todos.create { title, order, animateIn }
			newTodo.set( "tags", tags )
			if tags.length then swipy.tags.getTagsFromTasks()

			taskTitleLength = "1-10"
			if title.length > 50 then taskTitleLength = "50+"
			else if title.length > 41 then taskTitleLength = "41-50"
			else if title.length > 31 then taskTitleLength = "31-40"
			else if title.length > 21 then taskTitleLength = "21-30"
			else if title.length > 11 then taskTitleLength = "11-20"

			swipy.analytics.sendEvent("Tasks", "Added", "Input", taskTitleLength )
		destroy: ->
			Backbone.off( null, null, @ )