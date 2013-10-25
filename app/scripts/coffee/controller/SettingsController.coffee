define ["underscore", "backbone", "view/settings/SettingsOverlay", "model/SettingsModel"], (_, Backbone, SettingsOverlayView, SettingsModel) ->
	class SettingsController
		constructor: (opts) ->
			@init()
		init: ->
			@model = new SettingsModel()

			Backbone.on( "show-settings", @show, @ )
			Backbone.on( "hide-settings", @hide, @ )

			_.bindAll( @, "get", "set", "unset" )
		get: ->
			@model.get arguments...
		set: ->
			@model.set arguments...
		unset: ->
			@model.unset arguments...
		show: ->
			if not @view?
				@view = new SettingsOverlayView( model: @model )
				$("body").append @view.render().el

			@view.show()
		hide: ->
			@view?.hide()
		destroy: ->
			@view?.remove()
			Backbone.off( null, null, @ )