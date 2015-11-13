define ["js/utility/Utility"], ( Utility ) ->
	Backbone.Model.extend
		className: "BaseModel"
		defaultAttributes: [ "objectId", "tempId", "deleted", "ownerId", "userId", "createdAt" ]
		idAttribute: "objectId"
		attrWhitelist: []
		sync: -> true
		set: ( key, val, options ) ->
			Backbone.Model.prototype.set.apply @ , arguments
			attrs = {}
			if key is null or typeof key is 'object'
				attrs = key
				options = val
			else 
				attrs[ key ] = val
			if options and options.localSync
				@doSync.apply @ , []
		save: ->
			shouldSync = @handleForSync.apply @ , arguments
			Backbone.Model.prototype.save.apply @ , arguments
			if shouldSync
				@doSync.apply @ , []
		constructor: ( attributes ) ->
			me = swipy.swipesCollections.users.me()
			if attributes && !attributes.objectId
				util = new Utility()
				attributes.userId = me.id
				attributes.tempId = util.generateId 12
				attributes.objectId = attributes.tempId
				attributes.needSaveToServer = true
			Backbone.Model.apply @, arguments
			@reviveDate "createdAt"
			@reviveDate "updatedAt"
			@on "change:createdAt", =>
				@reviveDate "createdAt"
			@on "change:updatedAt", =>
				@reviveDate "updatedAt"
		reviveDate: (prop) ->
			value = @handleDateFromServer @get( prop )
			@set prop, value, { silent: true }
		handleDateFromServer: ( date ) ->
			if typeof date is "string"
				date = new Date date
			else if _.isObject( date ) and date.__type is "Date"
				date = new Date date.iso
			date
		deleteObj: ->
			@save "deleted", yes, { silent:true, sync: true }
		handleForSync: ( key, val, options ) ->
			attrs = {}
			if key is null or typeof key is 'object'
				attrs = key
				options = val
			else 
				attrs[ key ] = val
			if options and options.sync
				swipy.sync.handleModelForSync( @, attrs )
				return true
			return false
		doSync: (create) ->
			command = "update"
			if @isNew() # or create? and create
				command = "create"
			if @get "deleted"
				command = "delete"
			Backbone.sync(command, @)
			if command is "delete"
				if @className is "ToDo"
					swipy.collections.todos.remove(@)
				else if @className is "Tag"
					swipy.collections.tags.remove(@)
				else if @className is "Project"
					swipy.collections.projects.remove(@)
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


		# Update object from server
		updateFromServerObj: ( obj, recentChanges ) ->
			if @get("needSaveToServer")
				@set("needSaveToServer", false, {localSync: true})

			@set "deleted", obj.deleted, {localSync: true} if obj.deleted
			return if @get "deleted"

			keys = _.keys(obj)
			for attribute in @defaultAttributes
				continue if recentChanges? and _.indexOf recentChanges, attribute isnt -1
				continue if _.indexOf(keys, attribute) is -1
				val = obj[ attribute ]
				@set attribute, val, { localSync: true } if val isnt @get(attribute)

			for attribute in @attrWhitelist
				continue if recentChanges? and _.indexOf recentChanges, attribute isnt -1
				continue if _.indexOf(keys, attribute) is -1
				val = obj[ attribute ]
				val = @handleAttributeAndValueFromServer(attribute, val) if _.isFunction(@handleAttributeAndValueFromServer)
				@set(attribute, val, { localSync: true }) if val isnt @get(attribute)
			@doSync()