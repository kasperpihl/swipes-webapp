define ["underscore"], (_) ->
	Backbone.Model.extend
		className: "Settings"
		initialize: ->
			@debouncedSync = _.debounce(@syncSettings, 500)
			_.bindAll( @, "syncSettings" )
			@on( "change:Setting24HourClock", ->
				swipy.collections.todos.invoke( "setTimeStr" )
			)
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

			SettingCalendarStartMonday:
				false
			Setting24HourClock:
				false
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
				if @has(key)
					if key is "SettingWeekStart" or key is "SettingWeekendStart"
						value = parseInt(value, 10) - 1
					currentValue = @get(key)
					if value isnt currentValue
						@set key, value, {silent: true}
		set: (key, val, options)->
			Backbone.Model.prototype.set.apply @ , arguments
			try localStorage.setItem("SettingModel", JSON.stringify(@toJSON()))
			catch e then console.log e
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
			pickedValues = _.pick( defaultJson, @syncedSettings )
			pickedValues["SettingWeekStart"] = pickedValues["SettingWeekStart"] + 1
			pickedValues["SettingWeekendStart"] = pickedValues["SettingWeekendStart"] + 1
			pickedValues
		syncSettings: ->
			Backbone.trigger("sync-settings")