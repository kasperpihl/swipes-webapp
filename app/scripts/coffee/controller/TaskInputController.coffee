define ["underscore", "view/TaskInput", "model/TagModel"], (_, TaskInputView, TagModel) ->
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
			swipy.todos.create { title, tags, order, animateIn }

			if tags.length then swipy.tags.getTagsFromTasks()

			taskTitleLength = "1-10"
			if 11 <= title.length > 20 then taskTitleLength = "11-20"
			else if 21 <= title.length > 30 then taskTitleLength = "21-30"
			else if 31 <= title.length > 40 then taskTitleLength = "31-40"
			else if 41 <= title.length > 50 then taskTitleLength = "41-50"
			else if 50 < title.length then taskTitleLength = "50+"

			swipy.analyics.tagEvent( "Added Task", { length: taskTitleLength } )
		destroy: ->
			Backbone.off( null, null, @ )