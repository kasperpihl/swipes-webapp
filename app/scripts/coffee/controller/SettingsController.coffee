define ["underscore", "js/model/SettingsModel"], (_, SettingsModel) ->
	class SettingsController
		constructor: (opts) ->
			@init()
		init: ->
			currentJson = localStorage.getItem("SettingModel")
			if currentJson
				modelData = $.parseJSON(currentJson)
			@model = new SettingsModel(modelData)

			_.bindAll( @, "get", "set", "unset" )
		get: ->
			@model.get arguments...
		set: ->
			@model.set arguments...
		unset: ->
			@model.unset arguments...
		destroy: ->