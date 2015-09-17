###
	The TaskList Class - Intended to be UI only for rendering a tasklist.
	Has a datasource to provide it with task models
	Has a delegate to notify when drag/drop/click/other actions occur
###
define [
	"underscore"
	"js/view/modules/Section"
	"js/view/searchlist/SearchResultRow"
	], (_, Section, SearchResultRow) ->
	Backbone.View.extend
		className: "search-result-list"
		initialize: ->
			# Set HTML tempalte for our list
			@bouncedRender = _.debounce(@render, 5)
			@listenTo( Backbone, "reload/searchresult", @bouncedRender )
			@hasRendered = false
		remove: ->
			@cleanUp()
			@$el.empty()
			
		# Reload datasource for 

		render: ->
			if !@dataSource?
				throw new Error("SearchList must have dataSource")
			if !_.isFunction(@dataSource.searchListDataForSection)
				throw new Error("SearchList dataSource must implement searchListDataForSection")

			if !@targetSelector?
				throw new Error("SearchList must have targetSelector to render")

			@$el.html ""
			$(@targetSelector).html( @$el )


			numberOfSections = 1
			
			if _.isFunction(@dataSource.searchListNumberOfSections)
				numberOfSections = @dataSource.searchListNumberOfSections( @ )

			startTime = new Date().getTime()
			for section in [1 .. numberOfSections]
				# Load messages and titles for section
				sectionData = @dataSource.searchListDataForSection( @, section )
				continue if !sectionData or !sectionData.results.length

				# Instantiate
				section = new Section()
				section.setTitles(sectionData.leftTitle, sectionData.rightTitle)

				sectionEl = section.$el.find('.section-list')
			
				for result in sectionData.results
					resultView = new SearchResultRow({model: result})
					resultView.render()
					sectionEl.append( resultView.el )
				@$el.append section.el

			@hasRendered = true
			
		customCleanUp: ->
		cleanUp: ->
			@dataSource = null
			@delegate = null
			@chatDelegate = null
			# A hook for the subviews to do custom clean ups
			@customCleanUp()
			@stopListening()