define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.Collection.extend
		initialize: ->
			@getTagsFromTasks()
		getTagsFromTasks: ->
			tags = []
			swipy.todos.each (m) ->
				if m.has "tags" then tags.push tag for tag in m.get "tags"

			# Remove any duplicates (Created when multiple tasks share the same tag)
			tags = _.unique tags
			
			# Finally add tags to our collection
			@add { title: tagname } for tagname in tags
				
		