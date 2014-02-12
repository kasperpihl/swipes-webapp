define ["underscore", "backbone"], (_, Backbone) ->
	class FilterController
		constructor: ->
			@tagsFilter = []
			@searchFilter = ""

			@debouncedSearch = _.debounce( @applySearchFilter, 100 )
			@debouncedClearSearch = _.debounce( @removeSearchFilter, 100 )

			Backbone.on( "apply-filter", @applyFilter, @ )
			Backbone.on( "remove-filter", @removeFilter, @ )

			Backbone.on( 'navigate/view', @clearFilters, @ )
		applyFilter: (type, filter) ->
			if type is "tag" then @applyTagsFilter filter else @debouncedSearch filter

		removeFilter: (type, filter) ->
			if type is "tag" then @removeTagsFilter filter else @debouncedClearSearch filter

		clearFilters: ->
			if @searchFilter.length then @removeSearchFilter()
			if @tagsFilter.length
				@tagsFilter = []
				@removeTagsFilter()

		applyTagsFilter: (addTag) ->
			if (addTag) and not _.contains( @tagsFilter, addTag )
				@tagsFilter.push addTag

			for task in swipy.todos.models
				reject = yes

				if task.has( "tags" ) and _.intersection( task.getTagStrList(), @tagsFilter ).length is @tagsFilter.length
					reject = no

				task.set( "rejectedByTag", reject )

		applySearchFilter: (filter) ->
			@searchFilter = filter

			swipy.todos.each (model) =>
				isRejected = model.get( "title" ).toLowerCase().indexOf( @searchFilter ) is -1
				model.set( "rejectedBySearch", isRejected )

		removeTagsFilter: (tag) ->
			@tagsFilter = _.without( @tagsFilter, tag )

			if @tagsFilter.length is 0
				swipy.todos.invoke( "set", "rejectedByTag", no )
			else
				@applyTagsFilter()

		removeSearchFilter: (filter) ->
			@searchFilter = ""
			swipy.todos.invoke( "set", "rejectedBySearch", no )

		destroy: ->
			Backbone.off( null, null, @ )
