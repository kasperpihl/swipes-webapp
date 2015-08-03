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
		comparator: (m1, m2) ->
			m1Wins = 1
			m2Wins = -1
			if m1.get("timestamp") and m2.get("timestamp")
				m1Unix = new Date( m1.get("timestamp") ).getTime()
				m2Unix = new Date( m2.get("timestamp") ).getTime()
			else if !m1.get("timestamp") and !m2.get("timestamp")
				m1Unix = m1.get("localCreatedAt").getTime()
				m2Unix = m2.get("localCreatedAt").getTime()

			if m1Unix? and m1Unix
				if m1Unix > m2Unix then return m1Wins else return m2Wins
			
			if m1.get("timestamp") and !m2.get("timestamp")
				return m2Wins
			else if !m1.get("timestamp") and m2.get("timestamp")
				return m1Wins
			console.log "m1 here"
			m1Wins	
#			return new Date(message.get("timestamp")).getTime() if message.get("timestamp")
#			return message.get("localCreatedAt").getTime()
		initialize: ->
		destroy: ->