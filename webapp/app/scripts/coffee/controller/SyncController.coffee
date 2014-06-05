###
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync

###

define ["underscore", "backbone", "jquery", "controller/ChangedAttributesController"], (_, Backbone, $, ChangedAttributesController) ->
	class SyncController
		constructor: ->
			@changedAttributes = new ChangedAttributesController();
			@isSyncing = false
			@lastUpdate = null
			@sync()

		handleModelForSync: (model, attributes) ->
			@changedAttributes.saveAttributesToSync( model , attributes )
			console.log @changedAttributes.changedAttributes
		handleObjectsFromSync: ( objects, className ) ->
			collection = if className is "ToDo" then swipy.todos else swipy.tags
			newModels = []
			for obj in objects
				objectId = obj.objectId
				tempId = obj.tempId
				model = collection.find( 
					( model ) ->
						return if model.id is objectId or model.get 'tempId' is tempId then true else false
				)
				if !model
					model = new collection.model obj 
					newModels.push model
			if newModels.length > 0
				collection.add(
					newModels,
					silent : true
				)
				collection.trigger "reset"

		prepareObjects: ->
			console.log "prepare"


		sync: ->
			return if isSyncing
			isSyncing = true

			url = "http://localhost:5000/sync"
			user = Parse.User.current()
			token = user.getSessionToken()

			data =
				sessionToken : token

			serData = JSON.stringify data

			settings = 
				url : url
				type : 'POST'
				success : @responseFromSync
				error : @errorFromSync
				dataType : "json"
				contentType: "application/json; charset=utf-8"
				crossDomain : true
				context: @
				data : serData
				processData : false
			
			$.ajax( settings ) 
			@prepareObjects() if @lastUpdate?

		errorFromSync: ( data, textStatus, error ) ->
			@isSyncing = false
			console.log error
		responseFromSync: ( data, textStatus ) ->
			@isSyncing = false
			##console.log 'response'
			if data and data.serverTime
				@handleObjectsFromSync( data.Tag, "Tag" )
				@handleObjectsFromSync( data.ToDo, "ToDo" )
				@lastUpdate = data.updatedTime if data.updatedTime
				##swipy.todos.handleObjects data.ToDo