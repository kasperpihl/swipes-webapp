###
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync

###



define ["underscore", "backbone"], (_, Backbone) ->
	class SyncController
		constructor: ->
			@test = "yeah"
		saveToSync: (objects) ->
			@handleModelForSync object for object in objects
		handleModelForSync: (model) ->
			