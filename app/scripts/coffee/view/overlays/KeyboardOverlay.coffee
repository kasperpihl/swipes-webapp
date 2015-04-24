define ["underscore", 
		"js/view/Overlay", 
		"text!templates/keyboard-shortcuts-overlay.html", 
		], (_, Overlay, KeyboardOverlayTmpl) ->
	Overlay.extend
		className: 'overlay keyboard'
		events:
			"click .overlay-bg": "hide"
			
		initialize: ->
			@isMac = navigator.platform.toUpperCase().indexOf('MAC')>=0
			Overlay::initialize.apply( @, arguments )
			@showClassName = "keyboard-open"
			@hideClassName = "hide-keyboard"
		setTemplate: ->
			@template = _.template KeyboardOverlayTmpl
		render: ->
			if @template
				html = @template({ isMac: @isMac })
				@$el.html html

			return @
		afterShow: ->
			swipy.shortcuts.pushDelegate( @ )
		afterHide: ->
			swipy.shortcuts.popDelegate()
			@destroy()
		cleanUp: ->
			# Same as super() in real OOP programming
			Overlay::cleanUp.apply( @, arguments )