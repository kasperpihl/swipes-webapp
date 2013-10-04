define ["underscore", "backbone"], (_, Backbone) ->
	class FilterController
		constructor: ->
			@tagsFilter = []
			@searchFilter = ""
			
			Backbone.on( "apply-filter", @applyFilter, @ )
			Backbone.on( "remove-filter", @removeFilter, @ )
		applyFilter: (type, filter) ->
			if type is "tags" then @applyTagsFilter filter else @applySearchFilter filter

		removeFilter: (type, filter) ->
			if type is "tags" then @removeTagsFilter filter else @removeSearchFilter filter

		applyTagsFilter: (filter) ->
			console.log "Apply tags filter for #{filter}"

		applySearchFilter: (filter) ->
			console.log "Apply search filter for: #{filter}"

		removeTagsFilter: (filter) ->
			console.log "Remove tags filter for #{filter}"

		removeSearchFilter: (filter) ->
			# This is only called when search input is reset (text is deleted)
			console.log "Remove search filter for: #{filter}"

		getTasksThatMatchTags: (tagsArr) ->
