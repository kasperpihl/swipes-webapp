define ["underscore", "jquery"], (_, $) ->
	class ChangedAttributesController
		constructor: ->
			@changesKey = "changedAttributesKey"
			@tempChangesKey = "tempChangedAttributesKey"
			_.bindAll( @ , "saveAttributesToSync" )

			@newChangedAttributes = @collectionForKey(@changesKey)
			@tempChangedAttributes = @collectionForKey(@tempChangesKey)
		collectionForKey: (key) ->
			collection = localStorage.getItem(key)
			if collection
				collection = $.parseJSON( collection )
			collection = @newCollection() if !collection
			collection
		resetCollectionForKey:(key) ->
			collection = @newCollection()
			@saveCollectionForKey(key, collection)
			collection
		saveCollectionForKey: (key, collection) ->
			try localStorage.setItem(key, JSON.stringify(collection))
			catch e then console.log e
			
		newCollection: () ->
			"ToDo" : {}
			"Tag" : {}
			"Member": {}
			"Project": {}
			"Message": {}
			"Organisation": {}

		getChangesForModel: ( model ) ->
			if !model.get("needSaveToServer")
				return @newChangedAttributes[ model.className ][ model.id ]
			else
				return @tempChangedAttributes[ model.className ][ model.id ]
			return null

		saveAttributesToSync: ( model, attributes ) ->
			@_saveAttributesForSyncing @newChangedAttributes, model, attributes
			@saveCollectionForKey( @changesKey, @newChangedAttributes )
		saveTempAttributesToSync: ( model, attributes ) ->
			@_saveAttributesForSyncing @tempChangedAttributes, model, attributes
			@saveCollectionForKey( @tempChangesKey, @tempChangedAttributes )
		_saveAttributesForSyncing: ( collection, model, attributes ) ->
			identifier = model.id
			return if !identifier
			currentChanges = collection[ model.className ][ identifier ]
			attributes = _.keys attributes
			attributes = _.uniq( currentChanges.concat( attributes ) ) if currentChanges
			collection[ model.className ][ identifier ] = attributes

		getIdentifiersAndAttributesForSyncing: ( reset ) ->
			collection = $.parseJSON JSON.stringify @newChangedAttributes
			if reset
				@newChangedAttributes = @resetCollectionForKey(@changesKey)
			collection

		moveTempChangesForModel: ( model ) ->
			return if !model.get("needSaveToServer") or !model.get "tempId"?
			tempAttributes = @tempChangedAttributes[ model.className ][ model.get "tempId" ]
			@saveAttributesToSync model, tempAttributes if tempAttributes? and tempAttributes.length > 0
		resetChanges: ->
			
		resetTempChanges: ->
			@tempChangedAttributes = @resetCollectionForKey(@tempChangesKey)