define ["underscore"], (_) ->
	Backbone.View.extend
		events:
			"click li:not(.delete)": "handleClickTag"
			"click .delete": "toggleDeleteMode"
			"click .remove": "removeTag"
		initialize: ->
			@render = _.throttle( @render, 500 )

			@listenTo( swipy.tags, "add remove reset", @render )
			@listenTo( Backbone, "apply-filter remove-filter", @handleFilterChange )
			@listenTo( Backbone, "navigate/view", => _.defer => @render() )
			@listenTo( swipy.todos, "change:tags", @render )
			@render()
		handleFilterChange: (type) ->
			# We defer 'till next event loop, because we need to make sure
			# FilterController has done its thing first.
			_.defer =>
				if type is "tag" then @render()
		handleClickTag: (e) ->
			if @deleteMode
				@removeTag e
			else
				@toggleFilter e
		toggleDeleteMode: (e) ->
			e.stopPropagation()
			if @deleteMode then @deleteMode = off else @deleteMode = on
			@$el.toggleClass( "delete-mode", @deleteMode )
		toggleFilter: (e) ->
			tag = $.trim $( e.currentTarget ).text()
			el = $( e.currentTarget )

			unless el.hasClass "selected"
				Backbone.trigger( "apply-filter", "tag", tag )
			else
				Backbone.trigger( "remove-filter", "tag", tag )
		removeTag: (e) ->
			e.stopPropagation()
			tagName = $.trim $( e.currentTarget ).text()
			tag = swipy.tags.findWhere { title: tagName }


			wasSelected = $(e.currentTarget).hasClass "selected"

			if tag and confirm( "Are you sure you want to permenently delete this tag?" )
				tag.deleteObj()
				if wasSelected then Backbone.trigger( "remove-filter", "tag", tagName )
		getTagsForCurrentTasks: ->
			tags = []

			activeList = swipy.todos.getActiveList()
			switch activeList
				when "todo" then models = swipy.todos.getActive()
				when "scheduled" then models = swipy.todos.getScheduled()
				else models = swipy.todos.getCompleted()

			for model in models when model.has "tags"
				tags.push tagName for tagName in model.getTagStrList()

			return _.unique tags
		getValidatedTags: ->
			return swipy.tags.pluck "title"

			if swipy.filter? and swipy.filter.tagsFilter.length
				swipy.tags.getSiblings( swipy.filter.tagsFilter, no )
			else
				@getTagsForCurrentTasks()
		render: ->
			list = @$el.find ".rounded-tags"
			list.empty()

			# Sort alphabetically, case-insensitive
			tags = @getValidatedTags()
			tags = _.sortBy( tags, (tag) -> return tag.toLowerCase() )

			@renderTag( tag, list ) for tag in tags
			if tags.length then @renderDeleteButton list

			if @deleteMode
				@$el.toggleClass( "delete-mode", on )

			return @
		renderTag: (tagName, list) ->
			if swipy.filter? and _.contains( swipy.filter.tagsFilter, tagName )
				list.append "<li class='selected'>#{ tagName }</li>"
			else
				list.append "<li>#{ tagName }</li>"
		renderDeleteButton: (list) ->
			list.append "<li class='delete'><a href='JavaScript:void(0);' title='Delete tags'><span class='icon-trashcan'></span></a></li>"
		destroy: ->
			@stopListening()
			@undelegateEvents()


