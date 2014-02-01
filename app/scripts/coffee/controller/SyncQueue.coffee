define ["underscore", "backbone"], (_, Backbone) ->
	class SyncQueue
		constructor: ->
			@deferreds = []
		add: (promise) ->
			# Use jQuery deferred instead of crappy Parse deferred.
			# ... And since parse depends on Backbone, and thereby depends on jQuery,
			# why the fuck re-invent the deferred in a shittier version? gah! fuckers!
			dfd = new $.Deferred()

			# Use proxy functions to resolve our jQuery deferred when the Parse deferred
			# is resolved or failed.
			success = -> dfd.resolve()
			fail = -> dfd.reject()

			promise.then( success, fail )

			@deferreds.push( dfd );
		isBusy: ->
			_.any( @deferreds, (d) -> d.state() is "pending" )
		destroy: ->
			# We don't really need to do anything here...