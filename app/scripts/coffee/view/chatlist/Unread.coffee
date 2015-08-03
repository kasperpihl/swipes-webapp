define ["underscore"
		"text!templates/chatlist/unread.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		className: "unread-seperator"
		tagName: "li"
		initialize: ->
			@template = _.template Tmpl
			@render()
		setRead: ->
			@$el.addClass("read")
		render: ->
			@$el.html @template()
			return @
		remove: ->
			@$el.empty()