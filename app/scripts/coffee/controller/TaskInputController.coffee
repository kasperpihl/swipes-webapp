define ["underscore"], (_ ) ->
	class TaskInputController
		constructor: ->
			Backbone.on( "show-add", @showAddTask, @)
			Backbone.on( "create-task", @createTask, @ )
		showAddTask: ->
			
		parseTags: (str) ->
			result = str.match /#(.[^,#]+)/g

			if result
				# Trim white space and remove #-character from results
				tagNameList = ( $.trim tag.replace("#", "") for tag in result )
				tags = []

				for tagName in tagNameList
					tag = swipy.collections.tags.getTagByName tagName
					if !tag?
						tag = swipy.collections.tags.create( title: tagName )
						tag.save({}, {sync:true})

					tags.push tag

				return tags
			else
				return []

		parseTitle: (str) ->
			if str[0] is "#" then return ""

			result = str.match(/[^#]+/)?[0]
			if result then result = $.trim result
			return result
		createTask: (str, options) ->
			return unless swipy.collections.todos?

			tags = @parseTags str
			title = @parseTitle str
			animateIn = yes

			# If user is trying to add
			if !title
				msg = "You cannot create a todo by simply adding a tag. We need a title too. Titles should come before tags when you write out your task."
				alert( msg )
				return

			newTodo = swipy.collections.todos.create { title, animateIn }
			if options
				newTodo.set( "ownerId", options.ownerId) if options.ownerId
				newTodo.set( "projectLocalId", options.projectLocalId ) if options.projectLocalId
				newTodo.set( "toUserId", options.toUserId) if options.toUserId

			newTodo.set( "tags", tags )
			newTodo.save({}, {sync:true})

			swipy.analytics.sendEvent("Tasks", "Added", "Input", title.length )
			swipy.analytics.sendEventToIntercom( "Added Task", { "From": "Input", "Length": title.length } )

			if( options && options.open )
				swipy.router.navigate( "edit/#{ newTodo.id }", yes )
		destroy: ->
			Backbone.off( null, null, @ )