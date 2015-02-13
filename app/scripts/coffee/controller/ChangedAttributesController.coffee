define ["underscore", "jquery", "plugins/lockablestorage"], (_, $) ->
	class ChangedAttributesController
		constructor: ->
			@localKey = "changedAttributesStore"
			_.bindAll( @ , "saveAttributesToSync" )

			@newChangedAttributes = @newCollection()
			@tempChangedAttributes = @newCollection()

		###		initializeChanges: ->
			LockableStorage.lock( @localKey, =>
				localStorage[@localKey] = 
					"Tag": {} 
					"ToDo": {}
			)
		getAllChanges: ->
			localStorage.getItem( @localKey )###
		newCollection: () ->
			"ToDo" : {}
			"Tag" : {}

		getChangesForModel: ( model ) ->
			if model.id?
				return @newChangedAttributes[ model.className ][ model.id ]
			else if model.get "tempId"
				return @tempChangedAttributes[ model.className ][ model.get "tempId" ]
			return null

		saveAttributesToSync: ( model, attributes ) ->
			@_saveAttributesForSyncing @newChangedAttributes, model, attributes

		saveTempAttributesToSync: ( model, attributes ) ->
			@_saveAttributesForSyncing @tempChangedAttributes, model, attributes

		_saveAttributesForSyncing: ( collection, model, attributes ) ->
			identifier = if model.id? then model.id else model.get "tempId"
			return if !identifier
			currentChanges = collection[ model.className ][ identifier ]
			attributes = _.keys attributes
			attributes = _.uniq( currentChanges.concat( attributes ) ) if currentChanges
			collection[ model.className ][ identifier ] = attributes
		

		getIdentifiersAndAttributesForSyncing: ( reset ) ->
			collection = $.parseJSON JSON.stringify @newChangedAttributes
			@newChangedAttributes = @newCollection() if reset
			collection

		moveTempChangesForModel: ( model ) ->
			return if !model.id? or !model.get "tempId"?
			tempAttributes = @tempChangedAttributes[ model.className ][ model.get "tempId" ]
			saveAttributesToSync model, tempAttributes if tempAttributes? and tempAttributes.length > 0
		
		resetTempChanges: ->
			@tempChangedAttributes = @newCollection()