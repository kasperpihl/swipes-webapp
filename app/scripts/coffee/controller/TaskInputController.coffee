define ["underscore", "view/TaskInput"], (_, TaskInputView) ->
	class TaskInputController
		constructor: ->
			@view = new TaskInputView()
			Backbone.on( "create-task", @createTask, @ )
		parseTags: (str) ->
			result = str.match /#(.[^,]+)/g

			# Remove #-character from results
			result = ( tag.replace("#", "") for tag in result )

			return result
		parseTitle: (str) ->
			return "Looool"
		createTask: (str) ->
			return unless swipy.todos?
			
			tags = @parseTags str
			title = @parseTitle str
			order = 1

			swipy.todos.add { title, tags, order  }