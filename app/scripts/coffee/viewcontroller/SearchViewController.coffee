define [
	"underscore"
	"gsap"
	"text!templates/viewcontroller/search-view-controller.html"
	"js/view/searchlist/SearchList"
	], (_, TweenLite, Tmpl, SearchList) ->
	Backbone.View.extend
		className: "search-view-controller"
		initialize: ->
			@template = _.template Tmpl, {variable: "data" }
			@tailBounceSearch = _.debounce(@doSearch, 1000)
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
				@doSearch
			else
				@tailBounceSearch()
		getCurrentSection: ->
			currentSection = "messages"
			currentSection = "files" if @$el.find(".filter-option.selected").hasClass("files")
			currentSection
		clickedFilterOption: (e) ->
			el = $(e.currentTarget)
			@$el.find(".filter-option").removeClass("selected")
			el.addClass("selected")
			@renderSearch()
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
			text = @$el.find(".search-field-container input").val()
			if !text or !text.length
				@clearSearch()
			else if @currentResults? and @currentResults.query is text
				return false
			else
				return if @isLoading
				@setIsLoading(true)
				swipy.slackSync.apiRequest("search.all",{query: text, sort: "score"}, (res,error) =>
					if res and res.ok
						@setCurrentResults(res)
						@renderSearch()
					else 
						@currentResults = []
						@clearSearch()
					@setIsLoading(false)
				)
		setIsLoading:(isLoading) ->
			@isLoading = isLoading
			@$el.find(".search-field-container").toggleClass("isLoading", isLoading)
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