define [ "underscore", "js/model/sync/MessageModel", "localStorage"], ( _, MessageModel) ->
	Backbone.Collection.extend
		model: MessageModel
		localStorage: new Backbone.LocalStorage("MessageCollection")
		sendMessage: (message, options) ->
			newMessage = @create { message: message }
			if options
				newMessage.set( "ownerId", options.ownerId) if options.ownerId
				newMessage.set( "projectLocalId", options.projectLocalId ) if options.projectLocalId
				newMessage.set( "toUserId", options.toUserId) if options.toUserId
			newMessage.save({}, {sync:true})
		initialize: ->
		destroy: ->