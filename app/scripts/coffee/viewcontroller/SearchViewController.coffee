define [
	"underscore"
	"gsap"
	"text!templates/viewcontroller/search-view-controller.html"
	"js/view/searchlist/SearchList"
	], (_, TweenLite, Tmpl, SearchList) ->
	Backbone.View.extend
		className: "search-view-controller"
		pageNumber: 1,
		initialize: ->
			@template = _.template Tmpl, {variable: "data" }
			@tailBounceSearch = _.debounce(@doSearch, 500)
			_.bindAll(@, "doSearch")
			@searchList = new SearchList()
			@searchList.dataSource = @
			@searchList.targetSelector = ".search-result-container"
		events:
			"keyup input": "pressedKey"
			"keydown input": "keydownEvent"
			"click .filter-option" : "clickedFilterOption"
		pressedKey: (e) ->
			if e.keyCode is 27
				# T_TODO close search on escape would be nice
				#@doSearch
			else
				@toggleLoadingAnimation true
		getCurrentSection: ->
			currentSection = "messages"
			currentSection = "files" if @$el.find(".filter-option.selected").hasClass("files")
			currentSection
		clickedFilterOption: (e) ->
			el = $(e.currentTarget)
			@$el.find(".filter-option").removeClass("selected")
			el.addClass("selected")
			@pageNumber = 1

			if @currentResults
				@currentResults.query = ''
			@toggleLoadingAnimation true
			#@renderSearch()
		render: ->
			@$el.html @template({})
			$("#main").html(@$el)
			@$el.find(".search-field-container input").focus()
		open: (options) ->
			swipy.rightSidebarVC.sidebarDelegate = @
			swipy.topbarVC.setSectionTitleAndProgress("No results")
			swipy.topbarVC.setMainTitleAndEnableProgress("Search", false )
			swipy.rightSidebarVC.hideSidemenu()
			@render()
		doSearch: ->
			type = @getCurrentSection()
			text = @$el.find(".search-field-container input").val()

			return if @isLoading

			@isLoading = true

			swipy.swipesSync.apiRequest("search.all", {
				query: text
				sort: "timestamp"
				count: '50'
				page: @pageNumber
			}, (res,error) =>
				if res and res.ok
					@searchList.totalPages = res[type].paging.pages
					@setCurrentResults(res)
					@renderSearch()
				else
					@currentResults = []

				@isLoading = false
				@toggleLoadingAnimation false
			)
		toggleLoadingAnimation: (isVisible) ->
			text = @$el.find(".search-field-container input").val()
			loadingAnimation = @$el.find(".search-loading-container")

			if !text or !text.length
				@clearSearch()
				loadingAnimation.removeClass("isLoading")
			else if @currentResults? and @currentResults.query is text
				loadingAnimation.removeClass("isLoading")
				return false
			else
				@clearSearch()
				loadingAnimation.addClass("isLoading")
				@tailBounceSearch()
		setCurrentResults: (res) ->
			@currentResults = res
			numberOfMessages = res.messages.total
			@$el.find(".filter-option.messages").html("Messages ("+numberOfMessages+")")

			numberOfFiles = res.files.total
			@$el.find(".filter-option.files").html("Files ("+numberOfFiles+")")

			swipy.topbarVC.setSectionTitleAndProgress(+numberOfMessages+ + +numberOfFiles+ " results")
		renderSearch: ->
			@searchList.render()
		clearSearch: ->
			@$el.find(".search-result-container").html("")
			@$el.find(".filter-option.messages").html("Messages")
			@$el.find(".filter-option.files").html("Files")
			swipy.topbarVC.setSectionTitleAndProgress("No results")

		###
			SearchList Datasource
		###

		# SearchList asking for number of sections
		searchListNumberOfSections: ( chatList ) ->
			return 1
		searchListDataForSection: ( chatList, section ) ->
			return null if !@currentResults?
			if @getCurrentSection() is "messages"
				results = @currentResults.messages.matches
				group1 = {"results": results}
				return group1
			else if @getCurrentSection() is "files"
				results = @currentResults.files.matches
				group1 = {"results": results}
				return group1
			return null


		destroy: ->
			@chatList?.destroy()
			Backbone.off(null,null, @)
