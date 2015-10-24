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
			
			cursorIndex = e.currentTarget.selectionStart
			textBeforeCursor = fullText.substr(0, cursorIndex)
			iteratorIndex = cursorIndex
			
			### 
				Strategy:
				Get cursor position
				Go back each char
				break if newline or space
				if @ or # is found
					searchText is the string between
					showResults!
				else
					hide!

			###
			toggleShow = false
			while char = textBeforeCursor.charAt(--iteratorIndex)
				if char is " "
					break
				if char is "@" or char is "#"
					@searchStartIndex = iteratorIndex+1
					@searchLetter = char
					toggleShow = true
			return @toggleShown(false) if !toggleShow
			if !@shown
				@toggleShown(true)
			searchText = textBeforeCursor.substr(iteratorIndex+2)
			

			if @shown
				return false if e.keyCode is 27
				return false if e.keyCode is 38
				return false if e.keyCode is 40
				if e.keyCode is 13
					@sendResultAndClose()
					return false
				
			if !searchText or searchText isnt @searchText
				@searchText = searchText
				results = @dataSource.getResultsForTextAndSearchLetter?(@searchLetter, searchText)
				@setResults(results)
			return true
		sendResultAndClose: ->
			res = @results[@selectedIndex]
			# Delegate call with the result
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
			$listEl = @$el.find(".ac-result-list")
			$listEl.find("li.selected").removeClass("selected")
			$targetEl = $listEl.find("li#ac-item-" + el.id)
			if $targetEl
				$targetEl.addClass("selected")
				scrollPos = @$el.scrollTop()
				scrollContainerHeight = @$el.outerHeight()
				maxScrollPos = $listEl.outerHeight() - scrollContainerHeight
				elPos = $targetEl.position().top
				elHeight = $targetEl.outerHeight()
				extraScrollPadding = 10

				# check if el is above
				if elPos < extraScrollPadding
					newScroll = scrollPos + elPos - extraScrollPadding
				newScroll = 0 if newScroll < 0

				# check if el is below
				if elPos > scrollContainerHeight - elHeight - extraScrollPadding
					newScroll = scrollPos + elPos - scrollContainerHeight + elHeight + extraScrollPadding
				newScroll = maxScrollPos if newScroll > maxScrollPos
				
				if newScroll?
					#console.log newScroll
					@$el.scrollTop(newScroll)
				#console.log "scrolltop", scrollPos, scrollContainerHeight, contentTotalHeight


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
			@$el.scrollTop(0)
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
