###
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync

###

define ["underscore", "jquery", "js/controller/ChangedAttributesController", "js/view/modules/SyncIndicator", "js/utility/Utility"], (_, $, ChangedAttributesController, SyncIndicator, Utility) ->
	class SyncController

		constructor: ->
			@changedAttributes = new ChangedAttributesController()
			@syncIndicator = new SyncIndicator()
			$(".content-container").append @syncIndicator.el
			@isSyncing = false
			@needSync = false
			@lastUpdate = null
			@currentSyncVersion = 1
			if typeof(Storage) isnt "undefined"
				syncVersion = parseInt(localStorage.getItem("currentSyncVersion"))
				if !syncVersion? or syncVersion isnt @currentSyncVersion
					localStorage.removeItem("syncLastUpdate")
					localStorage.setItem("currentSyncVersion", @currentSyncVersion)
				if localStorage.getItem("syncLastUpdate")?
					@lastUpdate = localStorage.getItem("syncLastUpdate")
			@bouncedSync = _.debounce( @sync, 1500 )
			@currentSyncing = null
			@firstSync = false
			@util = new Utility()

		handleModelForSync: (model, attributes) ->
			if !model.get("needSaveToServer")
				@changedAttributes.saveAttributesToSync( model , attributes )
			else if @isSyncing
				@changedAttributes.saveTempAttributesToSync( model, attributes )
			@bouncedSync()

		handleObjectsFromSync: ( objects, className ) ->
			collection = swipy.collections.tags if className is "Tag"
			collection = swipy.collections.todos if className is "ToDo"
			collection = swipy.collections.members if className is "Member"
			collection = swipy.collections.projects if className is "Project"
			collection = swipy.collections.messages if className is "Message"
			if className is "ToDo"
				@updatedTodos = []
			newModels = []
			didAddMainTasks = false
			for obj in objects
				if obj.parentLocalId? and newModels.length > 0 and !didAddMainTasks
					collection.add newModels
					didAddMainTasks = true
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
					continue if model.get("restrictedForMe")
					if !obj.parentLocalId? and model.has("completionDate")
						completionDate = model.get("completionDate")
						if completionDate? and completionDate
							nowNumber = new Date().getTime()/1000
							compNumber = completionDate.getTime()/1000
							difference = nowNumber - compNumber
							if difference > (3600*24*30)
								continue

					if obj.parentLocalId? and obj.parentLocalId
						parent = collection.get(obj.parentLocalId)
						if !parent
							continue
					@changedAttributes.moveTempChangesForModel model
					if className is "Tag" and collection.getTagByName(model.get("title"))
						model.destroy()
						continue
						
					collection.add model
					newModels.push model
					model.doSync()
				else
					if className is "ToDo"
						@updatedTodos?.push( model.id )
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
			for className in ["Tag", "ToDo", "Project", "Member", "Message"]
				for identifier, newChanges of newAttributes[ className ]
					existingChanges = @currentSyncing[ className ][ identifier ]
					newChanges = _.uniq( existingChanges.concat( newChanges ) ) if existingChanges?
					@currentSyncing[ className ][ identifier ] = newChanges

		prepareObjectsToSaveOnServer: ->
			return if !swipy?
			newAttributes = @changedAttributes.getIdentifiersAndAttributesForSyncing( "reset" )
			@combineAttributes newAttributes

			newTags = @prepareNewObjectsForCollection swipy.collections.tags
			newTodos = @prepareNewObjectsForCollection swipy.collections.todos
			newProjects = @prepareNewObjectsForCollection swipy.collections.projects
			newMessages = @prepareNewObjectsForCollection swipy.collections.messages

			updateTags = @prepareUpdatesForCollection swipy.collections.tags, "Tag"
			updateTodos = @prepareUpdatesForCollection swipy.collections.todos, "ToDo"
			updateProjects = @prepareUpdatesForCollection swipy.collections.projects, "Project"
			updateMessages = @prepareUpdatesForCollection swipy.collections.messages, "Message"

			serverJSON =
				Tag : newTags.concat( updateTags )
				ToDo : newTodos.concat( updateTodos )
				Project: newProjects.concat( updateProjects )
				Message: newMessages.concat( updateMessages )

			return serverJSON

		sync: ->
			return @needSync = true if @isSyncing
			return if !Parse.User.current()
			@isSyncing = true
			url = "http://" + window.location.hostname + ":5000/v1/sync" #"https://api.swipesapp.com/v1/sync" #
			user = Parse.User.current()
			token = user.getSessionToken()
			data =
				sessionToken : token
				platform : "web"
				version: 1
				syncId: @util.generateId(6)
				sendLogs : false
				changesOnly : true

			data.lastUpdate = @lastUpdate if @lastUpdate

			objects = @prepareObjectsToSaveOnServer()
			if objects
				data.objects = objects

			serData = JSON.stringify data
			#@syncIndicator.show()
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
			#console.log serData
			$.ajax( settings )
		finalizeSync: ( error ) ->
			#@syncIndicator.hide()
			@isSyncing = false
			@changedAttributes.resetTempChanges()
			if @needSync
				@needSync = false
				@sync()
			else
				@bouncedSync()
			Backbone.trigger( "sync-complete", @updatedTodos )

			@updatedTodos = null
		errorFromSync: ( data, textStatus, error ) ->
			console.log data
			@util.sendError( data, "Sync Server Error")
			@finalizeSync()
		responseFromSync: ( data, textStatus ) ->
			if data and data.ok
				@currentSyncing = null
				@changedAttributes.resetChanges()
				@handleObjectsFromSync( data.Member, "Member" ) if data.Member?
				@handleObjectsFromSync( data.Project, "Project" ) if data.Project?
				@handleObjectsFromSync( data.Tag, "Tag" ) if data.Tag?
				@handleObjectsFromSync( data.ToDo, "ToDo" ) if data.ToDo?
				@handleObjectsFromSync( data.Message, "Message" ) if data.Message?

				if data.updateTime
					@lastUpdate = data.updateTime 
					if typeof(Storage) isnt "undefined"
						localStorage.setItem("syncLastUpdate", data.updateTime)
				if not @firstSync
					@firstSync = true
					swipy.analytics.updateIdentity()
				##swipy.collections.todos.handleObjects data.ToDo
			else
				@util.sendError( data, "Sync Error")
			@finalizeSync()