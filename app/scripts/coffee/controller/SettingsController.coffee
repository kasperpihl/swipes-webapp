define ["underscore", "backbone", "view/scheduler/SettingsOverlay", "model/SettingsModel"], (_, Backbone, SettingsOverlayView, SettingsModel) ->
	class SettingsController
		constructor: (opts) ->
			@init()
		init: ->
			@model = new SettingsModel()
			@view = new SettingsOverlayView( model: @model )
			$("body").append @view.render().el

			Backbone.on( "settings/view", @showView, @ )
			Backbone.on( "show-settings", @show, @ )
			Backbone.on( "hide-settings", @hide, @ )
		showView: (view) ->
			console.log "Show settings view: #{view}"
		destroy: ->
			@view.remove()
			Backbone.off( null, null, @ )