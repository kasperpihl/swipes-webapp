###
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync

###

define ["underscore", "backbone", "jquery", "js/controller/ChangedAttributesController"], (_, Backbone, $, ChangedAttributesController) ->
	class SyncController

		constructor: ->
			@changedAttributes = new ChangedAttributesController();
			@isSyncing = false
			@needSync = false
			@lastUpdate = null
			@sync()
			@bouncedSync = _.debounce( @sync, 3000 )
			@currentSyncing = null

		handleModelForSync: (model, attributes) ->
			if model.id
				@changedAttributes.saveAttributesToSync( model , attributes )
			else if @isSyncing and !model.id
				@changedAttributes.saveTempAttributesToSync( model, attributes )
			@bouncedSync()

		handleObjectsFromSync: ( objects, className ) ->
			collection = if className is "ToDo" then swipy.todos else swipy.tags
			newModels = []
			for obj in objects
				if obj.parentLocalId? and newModels.length > 0
					collection.add newModels
					newModels = []
				objectId = obj.objectId
				tempId = obj.tempId
				model = collection.find( 
					( model ) ->
						return true if objectId? and model.id is objectId
						return true if tempId? and model.get("tempId") is tempId
						false
				)
				if !model
					continue if obj.deleted
					model = new collection.model obj
					@changedAttributes.moveTempChangesForModel model
					collection.add model
					newModels.push model
				else
					recentChanges = @changedAttributes.getChangesForModel model
					model.updateFromServerObj obj, recentChanges
			if newModels.length > 0
				collection.add(
					newModels
				)

		prepareNewObjectsForCollection: ( collection ) ->
			newModels = collection.filter (model) -> 
				return (!model.id and model.get "tempId")
			serverJSON = []
			for mdl in newModels
				json = mdl.toServerJSON()
				serverJSON.push json
			serverJSON


		prepareUpdatesForCollection: ( collection, className ) ->
			updatedAttributes = @currentSyncing[ className ]
			serverJSON = []

			for objID, attr of updatedAttributes
				if _.indexOf( attr, "deleted" ) isnt -1
					deleteJSON = 
						objectId: objID
						deleted: true
					serverJSON.push deleteJSON
			identifiers = _.keys( updatedAttributes )
			
			updateModels = collection.filter (model) ->
				return (_.indexOf(identifiers , model.id ) isnt -1)
			for mdl in updateModels
				mdlsChanges = updatedAttributes[ mdl.id ]
				json = mdl.toServerJSON mdlsChanges
				json.objectId = mdl.id
				serverJSON.push json 
			serverJSON


		combineAttributes: ( newAttributes ) ->
			return @currentSyncing = newAttributes if !@currentSyncing?
			for className in ["Tag", "ToDo"]
				for identifier, newChanges of newAttributes[ className ]
					existingChanges = @currentSyncing[ className ][ identifier ]
					newChanges = _.uniq( existingChanges.concat( newChanges ) ) if existingChanges?
					@currentSyncing[ className ][ identifier ] = newChanges

		prepareObjectsToSaveOnServer: ->
			return if !swipy?
			newAttributes = @changedAttributes.getIdentifiersAndAttributesForSyncing( "reset" )
			@combineAttributes newAttributes

			newTags = @prepareNewObjectsForCollection swipy.tags
			newTodos = @prepareNewObjectsForCollection swipy.todos

			updateTags = @prepareUpdatesForCollection swipy.tags, "Tag"
			updateTodos = @prepareUpdatesForCollection swipy.todos, "ToDo"
			serverJSON =
				Tag : newTags.concat( updateTags )
				ToDo : newTodos.concat( updateTodos )
			return serverJSON



		sync: ->
			return @needSync = true if @isSyncing
			@isSyncing = true
			url = if liveEnvironment then "http://api.swipesapp.com/v1/sync" else "http://localhost:5000/v1/sync"
			user = Parse.User.current()
			token = user.getSessionToken()
			data =
				sessionToken : token
				platform : "web"
				version: 1
				sendLogs : true
				changesOnly : true

			data.lastUpdate = @lastUpdate if @lastUpdate

			objects = @prepareObjectsToSaveOnServer()
			if objects
				data.objects = objects

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
		finalizeSync: ( error ) ->
			@isSyncing = false
			@changedAttributes.resetTempChanges()
			if @needSync
				@needSync = false
				@sync( true )
			Backbone.trigger( "sync-complete", @ )
		errorFromSync: ( data, textStatus, error ) ->
			@finalizeSync()
		responseFromSync: ( data, textStatus ) ->
			if data and data.serverTime

				@currentSyncing = null;
				@handleObjectsFromSync( data.Tag, "Tag" ) if data.Tag?
				@handleObjectsFromSync( data.ToDo, "ToDo" ) if data.ToDo?
				@lastUpdate = data.updateTime if data.updateTime
				##swipy.todos.handleObjects data.ToDo
			@finalizeSync()