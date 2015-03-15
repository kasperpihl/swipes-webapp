###
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync

###

define ["underscore", "jquery", "js/controller/ChangedAttributesController", "js/view/SyncIndicator"], (_, $, ChangedAttributesController, SyncIndicator) ->
	class SyncController

		constructor: ->
			@changedAttributes = new ChangedAttributesController()
			@syncIndicator = new SyncIndicator()
			$(".container").append @syncIndicator.el
			@isSyncing = false
			@needSync = false
			@lastUpdate = null
			if typeof(Storage) isnt "undefined"
				if localStorage.getItem("syncLastUpdate")?
					@lastUpdate = localStorage.getItem("syncLastUpdate")
			@bouncedSync = _.debounce( @sync, 3000 )
			@currentSyncing = null
			@firstSync = false


		handleModelForSync: (model, attributes) ->
			if !model.get("needSaveToServer")
				@changedAttributes.saveAttributesToSync( model , attributes )
			else if @isSyncing
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
				model = collection.find( 
					( model ) ->
						return true if objectId? and model.id is objectId
						false
				)
				if !model
					continue if obj.deleted
					model = new collection.model obj
					if !obj.parentLocalId? and model.has("completionDate")
						completionDate = model.get("completionDate")
						if completionDate? and completionDate
							nowNumber = new Date().getTime()/1000
							compNumber = completionDate.getTime()/1000
							difference = nowNumber - compNumber
							if difference > (3600*24*30)
								continue
					@changedAttributes.moveTempChangesForModel model
					collection.add model
					newModels.push model
					model.doSync()
				else
					recentChanges = @changedAttributes.getChangesForModel model
					model.updateFromServerObj obj, recentChanges
			if newModels.length > 0
				collection.add(
					newModels
				)

		prepareNewObjectsForCollection: ( collection ) ->
			newModels = collection.filter (model) ->
				return (model.get "needSaveToServer")
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
			return if !Parse.User.current()
			@isSyncing = true
			url = "http://api.swipesapp.com/v1/sync" #http://localhost:5000/v1/sync" #
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
			@syncIndicator.show()
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
			@syncIndicator.hide()
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
				@currentSyncing = null
				@changedAttributes.resetChanges()
				@handleObjectsFromSync( data.Tag, "Tag" ) if data.Tag?
				@handleObjectsFromSync( data.ToDo, "ToDo" ) if data.ToDo?

				if data.updateTime
					@lastUpdate = data.updateTime 
					if typeof(Storage) isnt "undefined"
						localStorage.setItem("syncLastUpdate", data.updateTime)
				if not @firstSync
					@firstSync = true
					swipy.analytics.updateIdentity()
				##swipy.todos.handleObjects data.ToDo
			else
				console.log data
				console.log "sync"
			@finalizeSync()