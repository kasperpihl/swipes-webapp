define ["underscore"
		"text!templates/chatlist/new-message.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		className: "chat-new-message"
		offset: null
		initialize: ->
			self = @
			@placeholder = "Write new message"
			@template = _.template Tmpl, { variable: "data" }
			@render()
			_.bindAll(@, "pressedKey")
			
			textarea = @$el.find('textarea')
			@offset = textarea[0].offsetHeight - textarea[0].clientHeight
		events:
			"keyup textarea": "pressedKey"
			"keydown textarea": "keyDown"
			"click .attach-button-container": "clickedAttach"
			"change #file-input": "fileChanged"
		render: ->
			@$el.html @template({placeholder: @placeholder})
			@delegateEvents()
			return @
		setPlaceHolder: (placeholder) ->
			@placeholder = placeholder
			@$el.find('textarea').attr('placeholder',placeholder)
		autoExpand: () ->
			chatContainer = $('.chat-list-container')
			textarea = @$el.find('textarea')
			textarea.css('height', 'auto').css 'height', textarea[0].scrollHeight + @offset
			newMessageCont = $('.chat-new-message')
			newMessageContHeight = newMessageCont.height()
			chatContainer.css('height', 'calc(100% - ' + newMessageContHeight + 'px - 0px)')
			return
		pressedKey: (e) ->
			nowStamp = new Date().getTime()
			if !@lastSentTyping? or (@lastSentTyping + 3500) < nowStamp
				@lastSentTyping = new Date().getTime()
				if @addDelegate? and _.isFunction(@addDelegate.newMessageIsTyping)
					@addDelegate.newMessageIsTyping( @ )
			message = @$el.find("textarea").val()
			
			keepGoing = @autoCompleteList?.updateWithEventAndText(e, message)
			return false if !keepGoing
			if e.keyCode is 13 && !e.shiftKey
				@sendMessage()
			@autoExpand()
			return false
		keyDown: (e) ->
			keepGoing = @autoCompleteList?.keyDownHandling(e)
			return false if !keepGoing
			if e.keyCode is 13 and !e.shiftKey
				e.preventDefault()
		clickedAttach: ->
			$("#file-input").click()
		fileChanged: (e) ->
			file = $("#file-input")[0].files[0]
			if @addDelegate? and _.isFunction(@addDelegate.newFileSelected)
				@addDelegate.newFileSelected(@, file)
		setUploading: (isUploading) ->
			@$el.find(".attach-button-container").toggleClass("isUploading", isUploading)
		acListSelectedItem: (acList, result) ->
			message = @$el.find("textarea").val()

			# the parts of the new string, taking out the search string and prepare replacement
			firstPart = message.substr(0, acList.searchStartIndex)
			replacementText = result.name + " "
			lastPart = message.substr(acList.searchStartIndex+acList.searchText.length)
			
			newMessage = firstPart + replacementText + lastPart
			# Calculating where cursor should be after
			newSelectionIndex = acList.searchStartIndex + replacementText.length
			
			@$el.find("textarea").val(newMessage)
			@$el.find("textarea").focus()

			# normal js to set the cursor 
			textAreaJSEl = document.getElementById("new-message-textarea")
			textAreaJSEl.selectionStart = newSelectionIndex
			textAreaJSEl.selectionEnd = newSelectionIndex
		sendMessage: ->
			message = @$el.find("textarea").val()
			return if message.length is 0

			if @addDelegate? and _.isFunction(@addDelegate.newMessageSent)
				@addDelegate.newMessageSent( @, message )
			else
				throw new Error("NewMessage must have an addDelegate that implements newMessageSent")
			@$el.find("textarea").val ""
		remove: ->
			@destroy()
			@$el.empty()
		destroy: ->
			@undelegateEvents()