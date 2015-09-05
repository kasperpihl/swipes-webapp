define ["underscore"], (_) ->
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
                return if swipy.shortcuts.globalLock
                swipy.router.navigate(data, true)
            )
            @bridge.registerHandler('trigger', (data, responseCallback) ->
                Backbone.trigger(data)
            )
            @bridge.registerHandler('register-notifications', (data, responseCallback) ->
                swipy.collections.todos.addChangeListenerForBridge()
            )
            @bridge.registerHandler('intercom', (data, responseCallback) ->
                Intercom('show')
            )
            @bridge.registerHandler('add-task', (data, responseCallback) ->
                
            )
            #sessionToken = Parse.User.current()?.getSessionToken()
            #userId = Parse.User.current()?.id
            #@bridge.send({  sessionToken, userId })
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