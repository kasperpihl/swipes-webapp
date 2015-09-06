define ["underscore"], (_) ->
	class Utility
		generateId: ( length ) ->
			text = ""
			possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    
			for i in [0..length]
				text += possible.charAt(Math.floor(Math.random() * possible.length))
			return text
		slackTypeForId: (identifier) ->
			return if !identifier or !identifier.length
			determinator = identifier.charAt(0)
			type = switch determinator
				when "U" then "User"
				when "D" then "DM"
				when "G" then "Group"
				when "C" then "Channel"
				when "T" then "Team"
				else null
			return type
		escapeHtml: (string) ->
			entityMap = {
				"&": "&amp;"
				"<": "&lt;"
				">": "&gt;"
				'"': '&quot;'
				"'": '&#39;'
				"/": '&#x2F;'
			}
			String(string).replace(/[&<>"'\/]/g, (s) ->
				entityMap[s]
			)
		sendError: (error, type) ->
			me = swipy.slackCollections.users.me()
			ErrorObject = Parse.Object.extend("Error")
			errorObject = new ErrorObject()

			if error? and error
				errorObject.set( "code", error.status ) if error.status
				errorObject.set( "error", error.statusText ) if error.statusText
				errorObject.set( "code", error.code ) if error.code
				errorObject.set( "error", error.message ) if error.message
			errorObject.set( "Platform", "Web" )
			errorObject.set( "OSVersion", navigator.userAgent.toLowerCase() )
			errorObject.set( "type", type ) if type?
			errorObject.set( "user", me.id ) if me? and me.id
			errorObject.save()
