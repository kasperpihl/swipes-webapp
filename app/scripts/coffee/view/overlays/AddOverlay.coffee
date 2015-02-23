define ["underscore", "js/view/Overlay", "text!templates/add-overlay.html"], (_, Overlay, AddOverlayTmpl) ->
	Overlay.extend
		className: 'overlay add'
		initialize: ->
			Overlay::initialize.apply( @, arguments )
		events:
			"click .overlay-bg": "hide"
		setTemplate: ->
			@template = _.template AddOverlayTmpl
		render: ->
			if @template
				html = @template()
				@$el.html html

			return @
		afterShow: ->
			swipy.shortcuts.pushDelegate( @ )
		afterHide: ->
			swipy.shortcuts.popDelegate()
		cleanUp: ->
			Overlay::cleanUp.apply( @, arguments )

