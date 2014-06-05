define [], ->
	Parse.Object.extend
		className: "BaseModel"
		handleForSync: ( key, val, options ) ->
			attrs = {}
			if key is null or typeof key is 'object'
				attrs = key
				options = val
			else 
				attrs[ key ] = val
			if options and options.sync
				console.log options
				console.log attrs
				swipy.sync.handleModelForSync( @, attrs )