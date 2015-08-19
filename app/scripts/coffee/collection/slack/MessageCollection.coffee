define [ "underscore", "js/model/slack/MessageModel", "localStorage"], ( _, MessageModel) ->
	Backbone.Collection.extend
		model: MessageModel
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
			m1.get("ts")
			if m1.get("ts") and m2.get("ts")
				m1Unix = m1.get("ts")
				m2Unix = m2.get("ts")
			else if !m1.get("ts") and !m2.get("ts")
				true

			if m1Unix? and m1Unix
				if m1Unix > m2Unix then return m1Wins else return m2Wins
			
			if m1.get("ts") and !m2.get("ts")
				return m2Wins
			else if !m1.get("ts") and m2.get("ts")
				return m1Wins
			console.log "m1 here"
			m1Wins	
#			return new Date(message.get("timestamp")).getTime() if message.get("timestamp")
#			return message.get("localCreatedAt").getTime()
		initialize: ->
		destroy: ->