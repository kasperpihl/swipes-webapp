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

		###*
		 * Looks at a tag (Or an array of tags), finds all the tasks that are tagged with those tags.
		 * (If multiple tags are passed, the tasks must have all of the tags applied to them)
		 * The method then finds and returns a list of other tags that those tasks have been tagged with.
		 *
		 * For example, if we have three tasks like this
		 * Task 1
		 * 		- tags: Nina
		 * Task 2
		 * 		- tagged: Nina, Pinta
		 * Task 3
		 * 		- tagged: Nina, Pinta, Santa-Maria
		 *
		 * If you call getSibling( "Nina" ) you will get
		 * [ "Pinta", "Santa-Maria" ] as the return value.
		 *
		 *
		 * @param  {String/Array} tags a string or an array of strings (Tagnames)
		 * @param  {Boolean} excludeOriginals if false, the original tags, the ones the siblings are based on, will be included in the result
		 *
		 * @return {array}     an array with the results. No results will return an empty array
		###
		getSiblings: (tags, excludeOriginals = yes) ->
			# If string, wrap it in an array so we can loop over it
			if typeof tags isnt "object" then tags = [tags]

			result = []
			for task in swipy.todos.getTasksTaggedWith tags
				result.push task.get "tags"

			# Make sure only to include the tags that are applied to ALL of the tasks
			result = _.flatten result

			# Make sure we have no duplicates
			result = _.unique result

			console.log "based on ", tags, " the result is: ", result

			# Finally remove the initial tag from the results.
			if excludeOriginals
				return _.without( result, tags... )
			else
				return result
		handleTagDeleted: (model) ->
			tagName = model.get "title"

			affectedTasks = swipy.todos.filter (m) ->
				m.has( "tags" ) and _.contains( m.get( "tags" ), tagName )

			for task in affectedTasks
				oldTags = task.get "tags"
				task.unset( "tags", { silent: yes } )
				task.set( "tags", _.without( oldTags, tagName ) )
		destroy: ->
			@off( null, null, @ )
