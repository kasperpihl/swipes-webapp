define ["underscore"], (_) ->
	class Utility
		generateId: ( length ) ->
			text = ""
			possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    
			for i in [0..length]
				text += possible.charAt(Math.floor(Math.random() * possible.length))
			return text
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
			errorObject.set( "user", Parse.User.current() ) if Parse.User.current()
			errorObject.save()
