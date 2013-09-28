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
			# Hook for views extending me
		bindEvents: ->
			# Hook for views extending me
		init: ->
			# Hook for views extending me
		render: ->
			if @template
				html = @template {}
				@$el.html html
			
			return @
		show: ->
			if @shown then return
			@shown = yes
			$("body").toggleClass( 'overlay-open', yes )
			@afterShow()
		afterShow: ->
			# Hook for views extending me
		hide: ->
			if not @shown then return
			@shown = no
			$("body").toggleClass( 'overlay-open', no )
			afterHide()
		afterHide: ->
			# Hook for views extending me
		destroy: ->
			@hide().done => 
				@stopListening()
				$(document).off()
				@$el.empty()