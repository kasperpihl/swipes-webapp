define ["underscore"], (_) ->
	class SoundController
		constructor: (collection) ->
			@bouncedPlayNewMessage = _.debounce(@playNewMessage, 200, true)
			@_bouncedSecondMessage = _.debounce(@_playSecondMessageSound, 110) 
			Backbone.on( "play-new-message", @bouncedPlayNewMessage, @)
			@messageS1 = new Audio("sounds/newmessage.mp3")
			@messageS2 = new Audio("sounds/newmessage.mp3")
		playNewMessage: (args) ->
			if args and _.isNumber(args)
				@_bouncedSecondMessage = _.debounce(@_playSecondMessageSound, args)
			console.log("play new message", args)
			@messageS1.play()
			@_bouncedSecondMessage()
		_playSecondMessageSound: ->
			@messageS2.play()
		destroy: ->
			Backbone.off( null, null, @ )