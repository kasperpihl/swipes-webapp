define ["underscore"
		"text!templates/chatlist/thread-header.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		className: "thread-header"
		initialize: ->
			@template = _.template Tmpl, { variable: "data" }
			@title = "This is a thread. Here you can discuss related to the task."
			@render()
		events:
			"click .clear-button": "clickedClearButton"
		show: (show) ->
			showVar = false
			if show? and show
				showVar = true
			@$el.toggleClass("shown", showVar)
		render: ->
			@$el.html @template({title: @title})
			@delegateEvents()
			return @
		clickedClearButton: (e) ->
			if @clickDelegate? and _.isFunction(@clickDelegate.threadHeaderDidClickClear)
				@clickDelegate.threadHeaderDidClickClear(@)
		remove: ->
			@destroy()
			@$el.empty()
		destroy: ->
			@undelegateEvents()