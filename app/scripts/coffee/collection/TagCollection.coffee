define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.Collection.extend
		initialize: ->
			@getTagsFromTasks()
			@on( "remove", @handleTagDeleted, @ )
			@on( "add", @validateTag, @ )
		getTagsFromTasks: ->
			tags = []
			swipy.todos.each (m) ->
				if m.has "tags" then tags.push tag for tag in m.get "tags"

			# Remove any duplicates (Created when multiple tasks share the same tag)
			tags = _.unique tags

			# Finally add tags to our collection
			tagObjs = ( { title: tagname } for tagname in tags )
			@reset tagObjs

		validateTag: (model) ->
			if @where( { title: model.get "title" } ).length > 1
				@remove( model, { silent: yes } )
		handleTagDeleted: (model) ->
			tagName = model.get "title"

			affectedTasks = swipy.todos.filter (m) ->
				m.has( "tags" ) and _.contains( m.get( "tags" ), tagName )

			for task in affectedTasks
				oldTags = task.get "tags"
				task.unset( "tags", { silent: yes } )
				task.set( "tags", _.without( oldTags, tagName ) )
