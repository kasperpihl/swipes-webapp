define ["underscore", "backbone", "jquery", "js/plugins/lockablestorage"], (_, Backbone, $) ->
	class ChangedAttributesController
		constructor: ->
			@localKey = "changedAttributesStore"
			_.bindAll( @ , "saveAttributesToSync" )

			@newChangedAttributes = 
				"ToDo": {}
				"Tag": {}
		###		initializeChanges: ->
			LockableStorage.lock( @localKey, =>
				localStorage[@localKey] = 
					"Tag": {} 
					"ToDo": {}
			)
		getAllChanges: ->
			localStorage.getItem( @localKey )###
		saveAttributesToSync: ( model, attributes ) ->
			return if !model.id
			currentChanges = @newChangedAttributes[ model.className ][ model.id ]
			attributes = _.uniq(attributes.concat( currentChanges )) if currentChanges
			@newChangedAttributes[ model.className ][ model.id ] = _.keys attributes
		