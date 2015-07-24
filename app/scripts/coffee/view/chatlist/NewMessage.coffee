define ["underscore"
		"text!templates/chatlist/new-message.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		className: "chat-new-message"
		initialize: ->
			@template = _.template Tmpl, { variable: "data" }
			@render()
			_.bindAll(@, "pressedKey")
		events:
			"keyup input": "pressedKey"
		render: ->
			@$el.html @template({})
			@delegateEvents()
			return @
		setPlaceHolder: (placeholder) ->
			@$el.find('input').attr('placeholder',placeholder)
		pressedKey: (e) ->
			if e.keyCode is 13
				@sendMessage()
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