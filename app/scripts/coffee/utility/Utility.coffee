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
			errorObject.set( "user", me.toJSON() ) if me?
			errorObject.save()

		handleMentionsAndLinks: (text) ->
			return if !text

			matches = text.match(/<(.*?)>/g)

			if matches? and matches.length
				for match in matches
					replacement = ""
					match = match.substring(1, match.length-1)
					res = match.split("|")
					action = res[0]
					placeholder = action

					if res and res.length > 1
						placeholder = res[1]
					
					# URL handling
					if action.startsWith("http") or action.startsWith("mailto:")
						targetPart = "target=\"_blank\""

						if action.startsWith("http://swipesapp.com/forward")
							targetPart = "class=\"catchClick\""

						if action.startsWith("http://swipesapp.com/task/")
							action = "#" + action.substring("http://swipesapp.com/".length)
							targetPart = "class=\"catchClick\""

						if action.startsWith("mailto:")
							targetPart = ""

						replacement = "<a " + targetPart + " href=\""+action+"\">" + placeholder + "</a>"
						text = text.replace("<" + match+ ">", replacement)
						break
					else if action.startsWith("@U")
						user = swipy.slackCollections.users.get(action.substring(1))

						if user
							placeholder = user.get("name")
							replacement = "<a href=\"#im/"+placeholder+"\">@"+placeholder + "</a>"

						text = text.replace("<" + match+ ">", replacement)
						break
					else if action.startsWith("@C")
						placeholder = swipy.slackCollections.channels.get(action.substring(1)).get("name")
						replacement = "<a href=\"#channel/"+placeholder+"\">@"+placeholder + "</a>"
						text = text.replace("<" + match+ ">", replacement)
						break
					else
						text = _.escape text
						break

			text = text.replace(/(?:\r\n|\r|\n)/g, '<br>')

			return text