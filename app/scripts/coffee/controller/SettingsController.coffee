define ["underscore", "js/model/SettingsModel"], (_, SettingsModel) ->
	class SettingsController
		constructor: (opts) ->
			@init()
		events:
			"click #support-button": "clickedSupport"
		init: ->
			currentJson = localStorage.getItem("SettingModel")
			if currentJson
				modelData = $.parseJSON(currentJson)
			@model = new SettingsModel(modelData)

			Backbone.on( "show-settings", @show, @ )
			Backbone.on( "hide-settings", @hide, @ )

			_.bindAll( @, "get", "set", "unset" )
		clickedSupport: ->
			false
		get: ->
			@model.get arguments...
		set: ->
			@model.set arguments...
		unset: ->
			@model.unset arguments...
		show: ->
			if not @view? then require ["js/view/settings/SettingsOverlay"], (SettingsOverlayView) =>
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