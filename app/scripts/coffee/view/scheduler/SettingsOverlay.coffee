define ["underscore", "backbone", "view/Overlay", "text!templates/settings-overlay.html"], (_, Backbone, Overlay, SettingsOverlayTmpl) ->
	Overlay.extend
		className: 'overlay settings'
		initialize: ->
			@setTemplate()
			@bindEvents()
			
			@showClassName = "settings-open"
			@hideClassName = "hide-settings"
		bindEvents: ->
			_.bindAll( @, "handleResize" )
			$(window).on( "resize", @handleResize )
			Backbone.on( "settings/view", @showSubview, @ )
		setTemplate: ->
			@template = _.template SettingsOverlayTmpl
		render: ->
			html = @template {}
			@$el.html html
			return @
		afterShow: ->
			@handleResize()
		show: ->
			if Backbone.history.fragment is "settings" then @killSubView()
			Overlay::show.apply( @, arguments )
		showSubview: (subView) ->
			@killSubView().then =>
				# Make first letter uppercase
				viewName = subView[0].toUpperCase() + subView[1...]
				require ["view/settings/#{ viewName }"], (View) =>
					@subview = new View()
					@$el.find( ".overlay-content" ).append @subview.el
					@$el.addClass "has-active-subview"
		killSubView: ->
			if @subview? 
				@subview.remove().then => @$el.removeClass "has-active-subview"
			else 
				@$el.removeClass "has-active-subview"
				dfd = new $.Deferred()
				dfd.resolve()
				return dfd.promise()

		handleResize: ->
			return unless @shown
			content = @$el.find ".grid"
			offset = ( window.innerHeight / 2 ) - ( content.height() / 2 )
			content.css( "margin-top", offset )
			
