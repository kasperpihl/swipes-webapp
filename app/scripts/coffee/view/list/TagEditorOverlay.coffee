define ["underscore", "backbone", "view/Overlay", "text!templates/tags-editor-overlay.html"], (_, Backbone, Overlay, TagsEditorOverlayTmpl) ->
	Overlay.extend
		className: 'overlay tags-editor'
		events: 
			"click .overlay-bg": "hide"
			"click .close": "hide"
		initialize: ->
			Overlay::initialize.apply( @, arguments )
			@showClassName = "tags-editor-open"
			@hideClassName = "hide-tags-editor"
			@render()
		bindEvents: ->
			_.bindAll( @, "handleResize" )
			$(window).on( "resize", @handleResize )
		setTemplate: ->
			@template = _.template TagsEditorOverlayTmpl
		render: ->
			@$el.html @template( {} )
			$("body").append @$el
			@show()
			return @
		afterShow: ->
			@handleResize()
		afterHide: ->
			@destroy()
		handleResize: ->
			return unless @shown
			
			content = @$el.find ".overlay-content"
			offset = ( window.innerHeight / 2 ) - ( content.height() / 2 )
			content.css( "margin-top", offset )
		cleanUp: ->
			$(window).off()

			# Same as super() in real OOP programming
			Overlay::cleanUp.apply( @, arguments )
			
