define ["js/utility/Utility","backbone"], ( Utility ) ->
	Backbone.Model.extend
		className: "BaseModel"
		defaultAttributes: [ "objectId", "tempId", "deleted" ]
		sync: -> true
		constructor: ( attributes ) ->
			if attributes && !attributes.objectId
				util = new Utility()
				attributes.tempId = util.generateId 12
				console.log "generated tempId " + @className + " - " + attributes.tempId
			Backbone.Model.apply @, arguments
		handleForSync: ( key, val, options ) ->
			attrs = {}
			if key is null or typeof key is 'object'
				attrs = key
				options = val
			else 
				attrs[ key ] = val
			if options and options.sync
				swipy.sync.handleModelForSync( @, attrs )
		toServerJSON: ( attrList ) ->
			if !@attrWhitelist
				return console.log "please add attrWhiteList in model for sync support"
			attrList = @attrWhitelist.concat( @defaultAttributes ) if !attrList
			json = _.pick( @attributes, attrList )
			# Prepare all the dates to proper format for server
			for key, value of json
				if _.isDate value
					json[ key ] = { "__type": "Date", "iso": value }
			json

		updateFromServerObj: ( obj ) ->
			@id = obj.objectId if !@id?
			@set "deleted", obj.deleted if obj.deleted