###

###

define ["underscore", "jquery", "js/utility/Utility"], (_, $, Utility) ->
	class ClientAPIController
		constructor: (url)->
			throw new Error("No url set in constructor") if !url 
			_.bindAll(@, "_receivedMessageFromApp")
			# URL to client iframe, should be the iframe's base url
			@_url = url
			
			@_util = new Utility()
			
			# Timeout time for request 
			@_timeoutTimer = 10

			# Objects for containing timers and callback functions
			@_timers = {}
			@_callbacks = {}

			window.addEventListener("message", @_receivedMessageFromApp, false)

		_apiCall: (command, data, callback) ->
			console.log "_api call", command, data
			throw new Error("No doc/iframe set") if !@_doc
			
			identifier = @_util.generateId(10)
			callJson = {
				"ok": true,
				"identifier": identifier,
				"command": command,
				"data": data
			}
			if callback and _.isFunction(callback)
				@_addCallback(identifier, callback)

			@_doc.postMessage(JSON.stringify(callJson), @_url)
			
		_respondCall: (identifier, data, error) ->
			console.log @
			throw new Error("No doc/iframe set") if !@_doc
			callJson = {
				"reply_to": identifier,
			}
			if data 
				callJson.data = data
				callJson.ok = true
			if error
				callJson.ok = false
				callJson.error = error
			console.log("resonding", callJson)
			@_doc.postMessage(JSON.stringify(callJson), @_url)

		_receivedMessageFromApp: (msg) ->

			message = JSON.parse(msg.data)
			console.log "received main", message
			if message.reply_to
				@_doCallback(message.reply_to, message.data, message.error)
			else if message.identifier
				@_respondCall(message.identifier, {"test": true})

		_doCallback: (identifier, res, err) =>
			callback = @_callbacks[identifier]
			if callback
				callback(res, err)
			@_clearCallback(identifier)
		###
			Add callback for an identifier and set timeout to clear if not called before
		###
		_addCallback:(identifier, callback) ->
			@_callbacks[identifier] = callback
			@_timers[identifier] = setTimeout( =>
				if @? and @_callbacks[identifier]
					@_doCallback[identifier]("Timed out")
					
			, @_timeoutTimer * 1000)
		###
			Clear out callbacks and timers
		###
		_clearCallback: (identifier) ->
			delete @_callbacks[identifier] if @_callbacks[identifier]
			if @_timers[identifier]
				clearTimeout(@_timers[identifier])
				delete @_timers[identifier]


		destroy: ->
			window.removeEventListener("message", @_receivedMessageFromApp, false)
			for timer in @_timers
				console.log timer