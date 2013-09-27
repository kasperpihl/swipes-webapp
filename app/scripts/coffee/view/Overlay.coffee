define ["backbone"], (Backbone) ->
	Backbone.View.extend
		tagName: 'article'
		className: 'overlay'
		events:
			"click a.close": "hide"
		initialize: ->
			@setTemplate()
			@bindEvents()
			@init()
			
			# Remove overlay on ESC key
			$(document).on 'keyup', (e) =>
				if e.keyCode is 27 and @$el.html then @hide()
		setTemplate: ->
			
		bindEvents: ->
		init: ->
			# Hook for views extending me
		render: ->
			html = @template {}
			@$el.html html
			return @
		show: ->
			if @shown then return
			@shown = yes
			$("body").toggleClass( 'overlay-open', yes )
			@afterShow()
		afterShow: ->

		hide: ->
			if not @shown then return
			@shown = no
			$("body").toggleClass( 'overlay-open', no )
			afterHide()
		afterHide: ->

		destroy: ->
			@hide().done => 
				@stopListening()
				$(document).off()
				@$el.empty()