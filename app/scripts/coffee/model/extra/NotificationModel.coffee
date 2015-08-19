define ["underscore", "localStorage"], (_) ->
	Backbone.Model.extend
		localStorage: new Backbone.LocalStorage("NotificationModel")
		className: "Notification"
		initialize: ->
			return
			@bouncedHandleNotifications = _.debounce(@handleNotifications, 15)
			@listenTo( swipy.collections.messages, "add", @bouncedHandleNotifications)
			@listenTo( Backbone, "mark-read", @markRead )
			@fetch()
			@handleNotifications()
		identifierForMessage: (message) ->
			return
			if message.get("projectLocalId")
				identifier = "project-"+message.get("projectLocalId")
			else if message.get("toUserId")
				if message.get("toUserId") isnt Parse.User.current().id
					identifier = "member-" + message.get("toUserId")
					message.set("notification", true)
				else if message.get("userId") is Parse.User.current().identifier
					identifier = "personal"
				else
					identifier = "member-" + message.get("userId")
					message.set("notification", true)
			else
				identifier = "personal"
			identifier
		markRead: (identifier, timestring) ->
			return
			console.log "marking read", identifier, timestring
			return if !identifier or !timestring
			currentUnread = @get("unread")
			if !currentUnread
				currentUnread = {}
			currentUnread[identifier] = timestring
			@set("unread", null)
			@save("unread", currentUnread)
			@handleNotifications()
		getUnread: (identifier) ->
			return
			currentUnread = @get("unread")
			return currentUnread?[identifier]
		handleNotifications: ->
			return
			currentNotifications = @get("notifications")
			currentNotifications = {} if !currentNotifications
			currentUnread = @get("unread")
			currentUnread = {} if !currentUnread
			newNotifications = {}
			swipy.collections.messages.each( (message) =>
				return if message.get("userId") is Parse.User.current().id

				identifier = @identifierForMessage(message)
				lastRead = currentUnread[identifier]
				notifications = newNotifications[identifier]
				if !notifications
					notifications = { unread: false, notifications: 0 }

				if lastRead
					lastRead = new Date(lastRead)

				timestamp = new Date(message.get("timestamp"))
				
				if !lastRead or lastRead.getTime() < timestamp.getTime()
					message.set("unread",true)	
					notifications.unread = true
					if message.get("notification")
						notifications.notifications++
				else
					message.set("unread", false)
				newNotifications[identifier] = notifications
			)
			@save("notifications", newNotifications)