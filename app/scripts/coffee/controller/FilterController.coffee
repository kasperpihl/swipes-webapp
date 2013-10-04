define ["underscore", "backbone"], (_, Backbone) ->
	class FilterController
		constructor: ->
			@tagsFilter = []
			@searchFilter = ""
			
			Backbone.on( "apply-filter", @applyFilter, @ )
			Backbone.on( "remove-filter", @removeFilter, @ )
		applyFilter: (type, filter) ->
			if type is "tag" then @applyTagsFilter filter else @applySearchFilter filter

		removeFilter: (type, filter) ->
			if type is "tag" then @removeTagsFilter filter else @removeSearchFilter filter

		applyTagsFilter: (addTag) ->
			if (addTag) and not _.contains( @tagsFilter, addTag )
				@tagsFilter.push addTag
			
			for task in swipy.todos.models
				reject = yes
				
				if task.has( "tags" ) and _.intersection( task.get( "tags" ), @tagsFilter ).length is @tagsFilter.length
					reject = no

				console.log "Reject #{ task.get 'title' }: ", reject
				task.set( "rejectedByTag", reject )

		applySearchFilter: (filter) ->
			console.log "Apply search filter for: #{filter}"

		removeTagsFilter: (tag) ->
			@tagsFilter = _.without( @tagsFilter, tag )

			if @tagsFilter.length is 0
				swipy.todos.invoke( "set", "rejectedByTag", no )
			else
				@applyTagsFilter()

		removeSearchFilter: (filter) ->
			# This is only called when search input is reset (text is deleted)
			console.log "Remove search filter for: #{filter}"

		getTasksThatMatchTags: (tagsArr) ->
