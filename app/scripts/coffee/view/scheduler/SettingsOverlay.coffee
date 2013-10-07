define ["underscore", "backbone", "view/Overlay", "text!templates/settings-overlay.html"], (_, Backbone, Overlay, SettingsOverlayTmpl) ->
	Overlay.extend
		className: 'overlay settings'
		initialize: ->
			Overlay::initialize.apply( @, arguments )

			@showClassName = "settings-open"
			@hideClassName = "hide-settings"
		
		bindEvents: ->
			_.bindAll( @, "handleResize" )
			$(window).on( "resize", @handleResize )
		
		setTemplate: ->
			@template = _.template SettingsOverlayTmpl
		
		render: ->
			html = @template {}
			@$el.html html
			
			return @
		
		afterShow: ->
			@handleResize()
		
		handleResize: ->
			return unless @shown
			
			content = @$el.find ".overlay-content"
			offset = ( window.innerHeight / 2 ) - ( content.height() / 2 )
			content.css( "margin-top", offset )
			
