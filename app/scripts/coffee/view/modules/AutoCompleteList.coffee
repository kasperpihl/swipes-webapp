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
		keyDownHandling: (e) ->
			return true if !@shown
			if e.keyCode is 27
				@toggleShown(false)
				return false
			if e.keyCode is 38
				@selectPrev()
				return false
			if e.keyCode is 40
				@selectNext()
				return false
			if e.keyCode is 13
				return false
			return true
		updateWithEventAndText: (e, fullText) ->
			fullText = "" if !fullText? or !fullText
			return @toggleShown(false) if !fullText.length

			if !@shown
				lastLetter = fullText.substr(fullText.length - 1)
				if lastLetter is "@" or lastLetter is "#"
					@searchLetter = lastLetter
					@toggleShown(true, fullText.length)
			if @shown
				console.log e.keyCode
				return false if e.keyCode is 27
				return false if e.keyCode is 38
				return false if e.keyCode is 40
				if e.keyCode is 13
					@sendResultAndClose()
					return false
				

			searchText = fullText.substr(@startIndex)
			if !searchText or searchText isnt @searchText
				@searchText = searchText
				results = @dataSource.getResultsForTextAndSearchLetter?(@searchLetter, searchText)
				@setResults(results)
			return true
		sendResultAndClose: ->
			res = @results[@selectedIndex]
			@delegate?.acListSelectedItem?(@, res)
			
			@toggleShown(false)
		selectNext: ->
			@selectedIndex++
			if @selectedIndex >= @results.length
				@selectedIndex = 0
			@selectRow()
		selectPrev: ->
			@selectedIndex--
			if @selectedIndex < 0
				@selectedIndex = @results.length - 1
			@selectRow()
		selectRow: ->
			el = @results[@selectedIndex]
			@$el.find(".ac-result-list li.selected").removeClass("selected")
			$targetEl = @$el.find(".ac-result-list li#ac-item-" + el.id)
			if $targetEl
				$targetEl.addClass("selected")

		toggleShown: (toggle, startIndex) ->
			if startIndex?
				@startIndex = startIndex
			else @startIndex = -1
			if !toggle
				@setResults([])
			@shown = toggle
			@$el.toggleClass("shown", toggle)
		setResults: (results) ->
			@results = results
			@selectedIndex = 0
			$listEl = @$el.find(".ac-result-list")
			$listEl.html ""
			i = 0
			for item in results
				item.i = i++
				$listEl.append( @itemTemplate(item) )
			$listEl.find("li.ac-res-item").click((e) =>
				index = parseInt($(e.currentTarget).attr("data-href"))
				@selectedIndex = index
				@selectRow()
				@sendResultAndClose()
			)
			if results and results.length 
				@selectRow()
		remove: ->
			@cleanUp()
			@$el.empty()
		cleanUp: ->
			@dataSource = null
