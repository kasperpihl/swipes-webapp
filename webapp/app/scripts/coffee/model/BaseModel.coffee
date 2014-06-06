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
			if options
				if options.sync
					if @id
						swipy.sync.handleModelForSync( @, attrs )
		toServerJSON: ->
			if !@attrWhitelist
				return console.log "please add attrWhiteList in model for sync support"
			_.pick( @attributes, @attrWhitelist.concat( @defaultAttributes ) )