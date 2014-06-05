define ["underscore", "backbone", "gsap"], (_, Backbone, TweenLite) ->
	Backbone.View.extend
		tagName: "article"
		initialize: ->
			@setTemplate()
			@transitionInDfd = new $.Deferred()
			@render()
		setTemplate: ->
		render: ->
			if @template? then @$el.html @template {}
			@transitionIn()
		transitionIn: ->
			TweenLite.fromTo( @$el, 0.2, { alpha: 0 }, { alpha: 1, onComplete: @transitionInDfd.resolve } )
		transitionOut: ->
			dfd = new $.Deferred()
			TweenLite.to( @$el, 0.2, { alpha: 0, onComplete: dfd.resolve } )
			return dfd.promise()
		cleanUp: ->
			@stopListening()
			@undelegateEvents()
			@$el.remove()
		remove: ->
			dfd = new $.Deferred()
			@transitionOut().then =>
				@cleanUp()
				dfd.resolve()
			return dfd.promise()
