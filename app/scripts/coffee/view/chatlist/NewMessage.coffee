define ["underscore"
		"text!templates/chatlist/new-message.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		className: "chat-new-message"
		initialize: ->
			@placeholder = "Write new message"
			@template = _.template Tmpl, { variable: "data" }
			@render()

			_.bindAll(@, "pressedKey")
		events:
			"keyup input": "pressedKey"
			"click .attach-button-container": "clickedAttach"
			"change #file-input": "fileChanged"
		render: ->
			@$el.html @template({placeholder: @placeholder})
			@delegateEvents()
			return @
		setPlaceHolder: (placeholder) ->
			@placeholder = placeholder
			@$el.find('input').attr('placeholder',placeholder)
		pressedKey: (e) ->
			nowStamp = new Date().getTime()
			if !@lastSentTyping? or (@lastSentTyping + 3500) < nowStamp
				@lastSentTyping = new Date().getTime()
				if @addDelegate? and _.isFunction(@addDelegate.newMessageIsTyping)
					@addDelegate.newMessageIsTyping( @ )
			if e.keyCode is 13
				@sendMessage()
		clickedAttach: ->
			$("#file-input").click()
		fileChanged: (e) ->
			file = $("#file-input")[0].files[0]
			if @addDelegate? and _.isFunction(@addDelegate.newFileSelected)
				@addDelegate.newFileSelected(@, file)
		sendMessage: ->
			message = @$el.find("input").val()
			return if message.length is 0

			if @addDelegate? and _.isFunction(@addDelegate.newMessageSent)
				@addDelegate.newMessageSent( @, message )
			else
				throw new Error("NewMessage must have an addDelegate that implements newMessageSent")
			@$el.find("input").val ""
		remove: ->
			@destroy()
			@$el.empty()
		destroy: ->
			@undelegateEvents()