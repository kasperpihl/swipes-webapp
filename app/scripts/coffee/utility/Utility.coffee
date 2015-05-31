define ->
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