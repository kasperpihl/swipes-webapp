define ["backbone"], (Backbone) ->
	Backbone.View.extend
		tagName: 'article'
		className: 'overlay'
		events:
			"click a.close": "hide"
		initialize: ->
			@setTemplate()
			@bindEvents()
			
			@showClassName = "overlay-open"
			@hideClassName = "hide-overlay"
			
			# Remove overlay on ESC key
			$(document).on 'keyup', (e) =>
				if e.keyCode is 27 and @$el.html then @hide yes
		setTemplate: ->
			# Hook for views extending me
		bindEvents: ->
			# Hook for views extending me
		render: ->
			if @template
				html = @template {}
				@$el.html html
			
			return @
		show: ->
			if @shown then return
			@shown = yes

			$("body").removeClass @hideClassName
			if @hideTimer? then clearTimeout @hideTimer
			
			$("body").toggleClass( @showClassName, yes )
			@afterShow()
		afterShow: ->
			# Hook for views extending me
		hide: (cancelled = no) ->
			if not @shown then return
			@shown = no

			$("body").addClass @hideClassName
			@hideTimer = setTimeout =>
					$("body").toggleClass( @showClassName, no )
					@afterHide()
				, 400
					
		afterHide: ->
			# Hook for views extending me
		cleanUp: ->
			@stopListening()
			$(document).off()
		destroy: ->
			@hide().done => 
				@cleanUp()
				@$el.empty()
