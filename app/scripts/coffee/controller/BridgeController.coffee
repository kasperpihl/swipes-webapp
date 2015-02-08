define ["underscore"], () ->
    class BridgeController
        constructor: ->
            _.bindAll( @, "connectedBridge", "callHandler" )
            @connectWebViewJavascriptBridge @connectedBridge
        connectedBridge: (bridge) ->
            @bridge = bridge
            bridge.init( (message, responseCallback) ->
                if (responseCallback)
                    responseCallback("Right back atcha")
            )
            bridge.registerHandler('refresh', (data, responseCallback) ->
                swipy.sync.sync()
            )
        connectWebViewJavascriptBridge: (callback) ->
            if (window.WebViewJavascriptBridge)
                callback(WebViewJavascriptBridge)
            else
            document.addEventListener('WebViewJavascriptBridgeReady', () ->
                callback(WebViewJavascriptBridge)
            , false)
        callHandler: (handler, data, callback) ->
            console.log "trying"
            return if !@bridge?
            console.log "sending"
            @bridge.callHandler( handler, data, callback )