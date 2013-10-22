define ["underscore", "backbone"], (_, Backbone) ->
	class TaskInputController
		constructor: ->
			Backbone.on( "throw-error", @throwError, @ )
		throwError: ->
			console.warn arguments
			alert arguments[0]
		destroy: ->
			@throwError = null
			Backbone.off( "throw-error", @throwError )