define ["underscore", "backbone"], (_, Backbone) ->
	class TaskInputController
		constructor: ->
			Backbone.on( "throw-error", @throwError, @ )
		throwError: (err) ->
			console.warn err
			alert err
		destroy: ->
			@throwError = null
			Backbone.off( "throw-error", @throwError )