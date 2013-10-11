define ["underscore", "backbone", "view/scheduler/SettingsOverlay", "model/SettingsModel"], (_, Backbone, SettingsOverlayView, SettingsModel) ->
	class SettingsController
		constructor: (opts) ->
			@init()
		init: ->
			@model = new SettingsModel()
			@view = new SettingsOverlayView( model: @model )
			$("body").append @view.render().el

			Backbone.on( "show-settings", @view.show, @view )
			Backbone.on( "hide-settings", @view.hide, @view )

			_.bindAll( @, "get", "set" )
		get: ->
			@model.get arguments...
		set: ->
			@model.set arguments...
		unset: ->
			@model.unset arguments...
		destroy: ->
			@view.remove()
			Backbone.off( null, null, @ )