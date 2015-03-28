define ["underscore"], (_) ->
	class KeyboardController
		constructor: ->
			@pushedDelegates = []
			@delegate = null
			@lockDelegate = null
			@isLocked = false
			_.bindAll( @, "keyDownHandling", "keyUpHandling", "lock", "unlock", "handleClick" )
			$(document).on('keydown', @keyDownHandling )
			$(document).on('keyup', @keyUpHandling )
			$('#scrollcont').on("click.keycontroller", @handleClick)
			 
		destroy: ->
			$(document).off('keydown', @keyDownHandling )
			$(document).off('keyup', @keyUpHandling )
			$('#scrollcont').off("click.keycontroller")
		keyDownHandling: (e) ->
			if e.keyCode is 70 and e.metaKey or e.ctrlKey
				if Backbone.history.fragment isnt "search"
					swipy.router.navigate("search", true)
				e.preventDefault()
				return
			if e.keyCode is 83 and e.metaKey or e.ctrlKey
				if Backbone.history.fragment isnt "workspaces"
					swipy.router.navigate("workspaces", true)
				e.preventDefault()
				return
			if e.keyCode is 188 and e.metaKey or e.ctrlKey
				if Backbone.history.fragment isnt "settings"
					swipy.router.navigate("settings", true)
				e.preventDefault()
				return
			return if @isLocked or !@delegate?
			if _.isFunction(@delegate.keyDownHandling)
				@delegate.keyDownHandling(e)
		keyUpHandling: (e) ->
			return if @isLocked or !@delegate?
			if _.isFunction(@delegate.keyUpHandling)
				@delegate.keyUpHandling(e)
		handleClick: (e) ->
			if e.target.id is "scrollcont" and @delegate?
				if _.isFunction(@delegate.handleClick)
					@delegate.handleClick(e)

		setDelegate: ( delegate ) ->
			@delegate = delegate
			@pushedDelegates = []
		pushDelegate: ( delegate ) ->
			if @delegate?
				@pushedDelegates.push( @delegate )
			@delegate = delegate
		popDelegate: ->
			@delegate = @pushedDelegates.pop()
		lock: ->
			@isLocked = true
		unlock: ->
			@isLocked = false