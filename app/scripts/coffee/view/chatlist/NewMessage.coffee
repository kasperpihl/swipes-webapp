define ["underscore"
		"text!templates/chatlist/new-message.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		className: "chat-new-message"
		initialize: ->
			@template = _.template Tmpl, { variable: "data" }
			@render()
		events:
			"keyup input": "sendMessage"
		render: ->
			@$el.html @template({})
			@delegateEvents()
			return @
		setPlaceHolder: (placeholder) ->
			@$el.find('input').attr('placeholder',placeholder)
		sendMessage: (e) ->
			if e.keyCode is 13
				@triggerAddTask(e)
		remove: ->
		destroy: ->
			@undelegateEvents()