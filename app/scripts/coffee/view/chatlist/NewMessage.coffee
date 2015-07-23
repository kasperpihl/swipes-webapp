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
			if @addDelegate? and _.isFunction(@addDelegate.newMessageSent)
				@addDelegate.newMessageSent( @, @$el.find("input").val() )
			else
				throw new Error("NewMessage must have an addDelegate that implements newMessageSent")
		remove: ->
		destroy: ->
			@undelegateEvents()