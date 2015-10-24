###
	The TaskList Class - Intended to be UI only for rendering a tasklist.
	Has a datasource to provide it with task models
	Has a delegate to notify when drag/drop/click/other actions occur
###
define [
	"underscore"
	"text!templates/modules/auto-complete-list.html"
	"text!templates/modules/auto-complete-item.html"
	], (_, Tmpl, ItemTmpl) ->
	Backbone.View.extend
		className: "autocomplete-list"
		initialize: ->
			# Set HTML tempalte for our list
			@bouncedRender = _.debounce(@render, 10)
			@template = _.template Tmpl, {variable: "data" }
			@itemTemplate = _.template ItemTmpl, {variable: "data" }
			@render()


			#$(document).on('keydown', @keyDownHandling )
		render: ->
			@$el.html @template()
			@toggleShown(false)
		updateWithEventAndText: (e, fullText) ->
			fullText = "" if !fullText? or !fullText
			return @toggleShown(false) if !fullText.length

			if !@shown
				lastLetter = fullText.substr(fullText.length - 1)
				if lastLetter is "@" or lastLetter is "#"
					@searchLetter = lastLetter
					@toggleShown(true, fullText.length)


			searchText = fullText.substr(@startIndex)
			if !searchText or searchText isnt @searchText
				@searchText = searchText
				results = @dataSource.getResultsForTextAndSearchLetter(@searchLetter, searchText)
				@setResults(results)
			

		keyDownHandling: (e) ->
		toggleShown: (toggle, startIndex) ->
			if startIndex?
				@startIndex = startIndex
			else @startIndex = -1
			if !toggle
				@setResults([])
			@shown = toggle
			@$el.toggleClass("shown", toggle)
		setResults: (results) ->
			$listEl = @$el.find(".ac-result-list")
			$listEl.html ""

			for item in results
				$listEl.append( @itemTemplate(item) )
		remove: ->
			@cleanUp()
			@$el.empty()
		cleanUp: ->
			@dataSource = null
