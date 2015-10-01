define ["underscore"], (_) ->
	class KeyboardController
		constructor: ->
			@pushedDelegates = []
			@delegate = null
			@lockDelegate = null
			@isLocked = false
			@globalLock = false
			_.bindAll( @, "keyDownHandling", "keyUpHandling", "lock", "unlock", "handleClick" )
			$(document).on('keydown', @keyDownHandling )
			$(document).on('keyup', @keyUpHandling )
			$('.total-container').on("click.keycontroller", @handleClick)
			 
		destroy: ->
			$(document).off('keydown', @keyDownHandling )
			$(document).off('keyup', @keyUpHandling )
			$('.total-container').off("click.keycontroller")
		keyDownHandling: (e) ->
			if !@globalLock and !$("input").is(":focus") and !$("div.content-editable").is(':focus')
				if (e.metaKey or e.ctrlKey) and !(e.metaKey and e.ctrlKey)
					if e.keyCode is 49
						if Backbone.history.fragment isnt "tasks"
							swipy.router.navigate("tasks",true)
							e.preventDefault()
						return
					if e.keyCode is 188
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
		lock: (globalLock) ->
			@isLocked = true
			if globalLock
				@globalLock = true
		unlock: ->
			@isLocked = false
			@globalLock = false