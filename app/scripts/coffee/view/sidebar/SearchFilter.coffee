define ["underscore", "text!templates/sidemenu/sidemenu-search.html"], (_, SearchTmpl) ->
	Backbone.View.extend
		className: "search-filter"
		eventsJson:
			"submit form": "search"
			"keyup input": "search"
			"change input": "search"
		initialize: ->
			@template = _.template SearchTmpl
			@listenTo( Backbone, "apply-filter remove-filter", @handleFilterChange )
			@render()
			@delegateEvents(@eventsJson)
		keyUpHandling: (e) ->
			if e.keyCode is 27
				@$el.find('input').blur()
				swipy.sidebar.popView()
		search: (e) ->

			e.preventDefault()
			value = @$el.find('input').val()
			eventName = if value.length then "apply-filter" else "remove-filter"
			Backbone.trigger( eventName, "search", value.toLowerCase() )
		handleFilterChange: (type) ->
			# We defer 'till next event loop, because we need to make sure
			# FilterController has done its thing first.
			_.defer =>
				if type is "all" then @render()
		render: ->
			@$el.html @template {}
			searchString = ""
			searchString = swipy.filter.searchFilter if swipy.filter.searchFilter.length
			@$el.find('input').val(searchString)
		destroy: ->
			@stopListening()
			@undelegateEvents()