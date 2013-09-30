define ["underscore", "view/TaskInput"], (_, TaskInputView) ->
	class TaskInputController
		constructor: ->
			@view = new TaskInputView()
			Backbone.on( "create-task", @createTask, @ )
		parseTags: (str) ->
			result = str.match /#(.[^,#]+)/g

			# Trim and remove #-character from results
			result = ( $.trim tag.replace("#", "") for tag in result )

			return result
		parseTitle: (str) ->
			result = str.match(/.[^#]+/)?[0]
			if result then result = $.trim result

			return result
		createTask: (str) ->
			return unless swipy.todos?
			
			tags = @parseTags str
			title = @parseTitle str
			order = 1

			swipy.todos.add { title, tags, order  }