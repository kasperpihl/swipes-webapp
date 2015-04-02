define ["underscore"], () ->
    class BridgeController
        constructor: ->
            _.bindAll( @, "connectedBridge", "callHandler" )
            @connectWebViewJavascriptBridge @connectedBridge
        connectedBridge: (bridge) ->
            @bridge = bridge
            @bridge.init( (message, responseCallback) ->
                if (responseCallback)
                    responseCallback("Right back atcha")
            )
            @bridge.registerHandler('refresh', (data, responseCallback) ->
                swipy.sync.sync()
            )
            @bridge.registerHandler('navigate', (data, responseCallback) ->
                swipy.router.navigate(data, true)
            )
            @bridge.registerHandler('register-notifications', (data, responseCallback) ->
                swipy.todos.addChangeListenerForBridge()
            )
            @bridge.registerHandler('intercom', (data, responseCallback) ->
                Intercom('show')
            )
            sessionToken = Parse.User.current()?.getSessionToken()
            @bridge.send({  sessionToken})
        connectWebViewJavascriptBridge: (callback) ->
            if (window.WebViewJavascriptBridge)
                callback(window.WebViewJavascriptBridge)
            else

                document.addEventListener('WebViewJavascriptBridgeReady', () ->
                    callback(WebViewJavascriptBridge)
                , false)
        callHandler: (handler, data, callback) ->
            return if !@bridge?
            @bridge.callHandler( handler, data, callback )