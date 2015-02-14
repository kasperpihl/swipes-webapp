define ["underscore"], (_) ->
	Backbone.View.extend
		events:
			"submit form": "search"
			"keyup input": "search"
			"change input": "search"
		initialize: ->
			@input = $ "form input"
			@listenTo( Backbone, "apply-filter remove-filter", @handleFilterChange )
		search: (e) ->
			e.preventDefault()
			value = @input.val()

			eventName = if value.length then "apply-filter" else "remove-filter"
			Backbone.trigger( eventName, "search", value.toLowerCase() )
		handleFilterChange: (type) ->
			# We defer 'till next event loop, because we need to make sure
			# FilterController has done its thing first.
			_.defer =>
				if type is "all" then @render()
		render: ->
			searchString = ""
			searchString = swipy.filter.searchFilter if swipy.filter.searchFilter.length
			$('.search input').val(searchString)
		destroy: ->
			@stopListening()
			@undelegateEvents()