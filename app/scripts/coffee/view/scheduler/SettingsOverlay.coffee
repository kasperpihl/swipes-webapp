define ["underscore", "backbone", "view/Overlay", "text!templates/settings-overlay.html"], (_, Backbone, Overlay, SettingsOverlayTmpl) ->
	Overlay.extend
		className: 'overlay settings'
		bindEvents: ->
			
		setTemplate: ->
			@template = _.template SettingsOverlayTmpl
		render: ->
			html = @template {}
			@$el.html html
			
			return @
		afterShow: ->
			$("body").addClass "settings-open"
		afterHide: ->
			$("body").removeClass "settings-open"
			
