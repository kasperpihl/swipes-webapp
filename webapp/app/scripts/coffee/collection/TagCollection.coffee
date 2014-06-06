define [ "underscore", "js/model/TagModel", "backbone.localStorage"], ( _, TagModel) ->
	Backbone.Collection.extend
		model: TagModel
		localStorage: new Backbone.LocalStorage("TagCollection")
		initialize: ->
			@on( "remove", @handleTagDeleted )
			@on( "add", @handleAddTag, @ )

			@on "reset", ->
				removeThese = ( m for m in @models when m.get "deleted" )
				@remove( m, { silent: yes } ) for m in removeThese

		handleObjects: ( objects ) ->
			return false if !objects or objects.length is 0
			for obj in objects
				model = new @model obj
				console.log model
		getTagsFromTasks: ->
			tags = []
			for m in swipy.todos.models when m.has "tags"
				for tag in m.get "tags" when @validateTag tag
					# Make sure we don't get duplicates
					unless _.findWhere( tags, { cid: tag.cid } )
						tags.push tag

			# Finally add tags to our collection
			@reset tags

			# Save the models to the server if they are unsaved
			@saveNewTags()
		getTagByName: (tagName) ->
			tagName = tagName.toLowerCase()
			result = @filter (tag) -> tag.get("title").toLowerCase() is tagName
			if result.length
				return result[0]
			else
				return undefined
		saveNewTags: ->
			for model in @models when model.isNew()
				swipy.queue.add model.save()
		handleAddTag: (model) ->
			if not @validateTag model
				@remove( model, { silent: yes } )
		validateTag: (model) ->
			unless model.has "title"
				return false
			if @where( { title: model.get "title" } ).length > 1
				return false

			return true

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
				result.push _.invoke( task.get("tags"), "get", "title" )

			# Make sure only to include the tags that are applied to ALL of the tasks
			result = _.flatten result

			# Make sure we have no duplicates
			result = _.unique result

			# Finally remove the initial tag from the results.
			if excludeOriginals
				return _.reject( result, (tagName) -> _.contains( tags, tagName ) )
			else
				return result
		handleTagDeleted: (model) ->
			tagName = model.get "title"

			affectedTasks = swipy.todos.filter (m) ->
				m.has( "tags" ) and _.contains( m.getTagStrList(), tagName )

			for task in affectedTasks
				oldTags = task.get "tags"
				newTags = _.reject( oldTags, (tag) -> tag.get("title") is model.get "title" )
				task.updateTags newTags
		destroy: ->
			@off( null, null, @ )