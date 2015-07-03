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
			$('#scrollcont').on("click.keycontroller", @handleClick)
			 
		destroy: ->
			$(document).off('keydown', @keyDownHandling )
			$(document).off('keyup', @keyUpHandling )
			$('#scrollcont').off("click.keycontroller")
		keyDownHandling: (e) ->
			if !@globalLock and !$("input").is(":focus") and !$("div.content-editable").is(':focus')
				if (e.metaKey or e.ctrlKey) and !(e.metaKey and e.ctrlKey)
					if e.keyCode is 49
						if Backbone.history.fragment isnt "tasks/later"
							swipy.router.navigate("tasks/later",true)
							e.preventDefault()
						return
					if e.keyCode is 50
						if Backbone.history.fragment isnt "tasks/now"
							swipy.router.navigate("tasks/now",true )
							e.preventDefault()
						return
					if e.keyCode is 51
						if Backbone.history.fragment isnt "tasks/done"
							swipy.router.navigate("tasks/done",true )
							e.preventDefault()
						return
					if e.keyCode is 70
						if Backbone.history.fragment isnt "search"
							swipy.router.navigate("search", true)
						e.preventDefault()
						return
					if e.keyCode is 68
						if Backbone.history.fragment isnt "workspaces"
							swipy.router.navigate("workspaces", true)
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