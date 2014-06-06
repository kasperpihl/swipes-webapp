define ["backbone"], ->
	Backbone.Model.extend
		className: "BaseModel"
		sync: -> true
		handleForSync: ( key, val, options ) ->
			attrs = {}
			if key is null or typeof key is 'object'
				attrs = key
				options = val
			else 
				attrs[ key ] = val
			if options
				if options.sync
					swipy.sync.handleModelForSync( @, attrs )
				if options.fire
					for att, valOfAtt of attrs
						console.log att