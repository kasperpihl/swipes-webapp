define ["underscore", "backbone", "model/SettingsModel"], (_, Backbone, SettingsModel) ->
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
			if not @view? then require ["view/settings/SettingsOverlay"], (SettingsOverlayView) =>
				@view = new SettingsOverlayView( model: @model )
				$("body").append @view.render().el
				@view.show()
			else
				@view.show()

		hide: ->
			@view?.hide()
		destroy: ->
			@view?.remove()
			Backbone.off( null, null, @ )