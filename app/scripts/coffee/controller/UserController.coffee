define ["underscore"], (_) ->
	class SettingsController
		constructor: (opts) ->
			@init()
			@user = Parse.User.current()
			@fetchUser()
			_.bindAll( @, "syncSettings" )
			Backbone.on( "sync-settings", @syncSettings, @ )
		init: ->
			
		fetchUser: ->
			if @lastUserFetch?
				now = new Date()
				secondsDifference = (now.getTime() - @lastUserFetch.getTime())/1000
				if secondsDifference < 500
					return
			self = @
			@user.fetch({
				success: (object) ->
					self.lastUserFetch = new Date()
					settings = object.get("settings")
					if !settings?
						self.syncSettings()
					else
						swipy.settings.model.parseSettingsFromServer(settings)
					
				error: (object, error) ->
			})
		syncSettings: ->
			return if !@lastUserFetch?
			currentSettings = @user.get("settings")
			if !currentSettings?
				currentSettings = {}
			newSettings = swipy.settings.model.toSyncedJSON()
			for setting, value of newSettings
				currentSettings[setting] = value
			@user.set("settings",currentSettings, {silent: true})
			@user.save(null, {
				success: (object) ->
					
				error: (object, error) ->
			})