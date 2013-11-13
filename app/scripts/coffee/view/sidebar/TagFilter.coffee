define ["underscore", "backbone"], (_, Backbone) ->
	Backbone.View.extend
		events:
			"click li": "toggleFilter"
			"click .remove": "removeTag"
			"submit form": "createTag"
		initialize: ->
			@listenTo( swipy.tags, "add remove reset", @render )
			@listenTo( Backbone, "apply-filter remove-filter", @handleFilterChange )
			@listenTo( Backbone, "navigate/view", => _.defer => @render() )
			@render()
		handleFilterChange: (type) ->
			# We defer 'till next event loop, because we need to make sure
			# FilterController has done its thing first.
			_.defer =>
				if type is "tag" then @render()
		toggleFilter: (e) ->
			tag = $.trim $( e.currentTarget ).text()
			el = $( e.currentTarget )

			unless el.hasClass "selected"
				Backbone.trigger( "apply-filter", "tag", tag )
			else
				Backbone.trigger( "remove-filter", "tag", tag )
		createTag: (e) ->
			e.preventDefault()
			tagName = @$el.find("form.add-tag input").val()
			return if tagName is ""

			@addTag tagName
		addTag: (tagName) ->
			swipy.tags.add { title: tagName }
		removeTag: (e) ->
			e.stopPropagation()
			tagName = $.trim $( e.currentTarget.parentNode ).text()
			tag = swipy.tags.findWhere {title: tagName}

			wasSelected = $(e.currentTarget.parentNode).hasClass "selected"

			if tag and confirm( "Are you sure you want to permenently delete this tag?" ) then tag.destroy
				success: (model, response) ->
					swipy.todos.remove model
					if wasSelected then Backbone.trigger( "remove-filter", "tag", tagName )
				error: (model, response) ->
					alert "Something went wrong trying to delete the tag '#{ model.get 'title' }' please try again."
					console.warn "Error deleting tag — Response: ", response
		getTagsForCurrentTasks: ->
			tags = []

			activeList = swipy.todos.getActiveList()
			switch activeList
				when "todo" then models = swipy.todos.getActive()
				when "scheduled" then models = swipy.todos.getScheduled()
				else models = swipy.todos.getCompleted()

			for model in models when model.has "tags"
				tags.push tag for tag in model.get "tags"

			return _.unique tags
		getValidatedTags: ->
			if swipy.filter? and swipy.filter.tagsFilter.length
				swipy.tags.getSiblings( swipy.filter.tagsFilter, no )
			else
				@getTagsForCurrentTasks()
		render: ->
			list = @$el. find ".rounded-tags"
			list.empty()

			@renderTag tag, list for tag in @getValidatedTags()

			return @
		renderTag: (tag, list) ->
			if swipy.filter? and _.contains( swipy.filter.tagsFilter, tag )
				list.append "<li class='selected'>#{ tag }</li>"
			else
				list.append "<li>#{ tag }</li>"
		destroy: ->
			@stopListening()
			@undelegateEvents()


