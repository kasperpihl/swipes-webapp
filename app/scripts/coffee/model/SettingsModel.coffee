define ["underscore"], (_) ->
	Backbone.Model.extend
		className: "Settings"
		initialize: ->
			@debouncedSync = _.debounce(@syncSettings, 500)
			_.bindAll( @, "syncSettings" )
			@initialized = true
		defaults:
			SettingLaterToday:
				3 * 3600
			SettingEveningStartTime:
				19 * 3600
			SettingWeekStartTime:
				9 * 3600
			SettingWeekStart:
				1
			SettingWeekendStartTime:
				10 * 3600
			SettingWeekendStart:
				6
			SettingAddToBottom:
				false
			SettingFilter:
				""
		syncedSettings: [
			"SettingLaterToday"
			"SettingEveningStartTime"
			"SettingWeekStart"
			"SettingWeekStartTime"
			"SettingWeekendStart"
			"SettingWeekendStartTime"
			"SettingAddToBottom"
			"SettingFilter"
		]
		parseSettingsFromServer:( settings ) ->
			for key, value of settings
				if @has(key) and @get(key) isnt value
					@set key, value, {silent: true}
		set: (key, val, options)->
			Backbone.Model.prototype.set.apply @ , arguments
			localStorage.setItem("SettingModel", JSON.stringify(@toJSON()))
			if @debouncedSync?
				attrs = {}
				if key is null or typeof key is 'object'
					attrs = key
					options = val
				else 
					attrs[ key ] = val
				return if options? and options.silent
				for setting, value of attrs
					if _.indexOf(@syncedSettings, setting) isnt -1
						@debouncedSync()
		toSyncedJSON: ->
			defaultJson = @toJSON()
			_.pick( defaultJson, @syncedSettings )
		syncSettings: ->
			Backbone.trigger("sync-settings")