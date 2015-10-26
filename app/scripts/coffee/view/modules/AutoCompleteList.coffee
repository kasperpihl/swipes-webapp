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
			@lockMouseEvent = false

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
		selectRow: (dontScroll)->
			el = @results[@selectedIndex]

			# scrollEl should be the container set with overflow-y:scroll;
			$scrollEl = @$el
			# contentEl el should contain all the scrollable content in full length
			
			$contentEl = @$el.find(".ac-main-container")
			
			$listEl = @$el.find(".ac-result-list")
			$listEl.find("li.selected").removeClass("selected")
			
			$targetEl = $listEl.find("li#ac-item-" + el.id)
			
			if $targetEl
				$targetEl.addClass("selected")
				
				# current position of the scroll
				scrollPos = $scrollEl.scrollTop()

				# the height of the scroll window (not content!)
				scrollContainerHeight = $scrollEl.outerHeight()

				# the max scroll position allowed (full content height - scroll container height)
				maxScrollPos = $contentEl.outerHeight() - scrollContainerHeight
				
				# relative element position compared to scroll position
				elPos = $targetEl.position().top - scrollPos
				
				elHeight = $targetEl.outerHeight()
				
				# additional scroll spacing when moving up/down (0 would be element follow edge)
				extraScrollPadding = 30
				
				
				#console.log elPos, scrollContainerHeight
				
				# check if el is above
				if elPos < extraScrollPadding
					newScroll = scrollPos + elPos - extraScrollPadding
				newScroll = 0 if newScroll < 0

				# check if el is below
				if elPos > scrollContainerHeight - elHeight - extraScrollPadding
					newScroll = scrollPos + elPos - scrollContainerHeight + elHeight + extraScrollPadding
				newScroll = maxScrollPos if newScroll > maxScrollPos
				
				if newScroll? and !dontScroll?
					@lockMouseEvent = true
					$scrollEl.scrollTop(newScroll)
					setTimeout(=>
						if @?
							@lockMouseEvent = false
					,100)

				

		toggleShown: (toggle) ->
			if !toggle
				@setResults([])
			@shown = toggle
			@$el.toggleClass("shown", toggle)
		setResults: (results) ->
			@results = results
			@selectedIndex = 0
			$listEl = @$el.find(".ac-result-list")
			$scrollEl = @$el
			$listEl.html ""
			$scrollEl.scrollTop(0)
			i = 0
			for item in results
				item.i = i++
				$listEl.append( @itemTemplate(item) )
			$(".ac-result-list > li").on 'mouseover', (e) =>
				return if @lockMouseEvent
				el = $(e.currentTarget)
				@selectedIndex = parseInt(el.attr("data-href"))
				@selectRow(true)

			$listEl.find("li.ac-res-item").click((e) =>
				@sendResultAndClose()
			)
			if results and results.length 
				@selectRow()
		remove: ->
			@cleanUp()
			@$el.empty()
		cleanUp: ->
			@dataSource = null
