define [
	"underscore"
	"text!templates/viewcontroller/chat-list-view-controller.html"
	"js/view/chatlist/ChatList"
	"js/view/chatlist/NewMessage"
	"js/handler/ChatHandler"
	"js/view/chatlist/ThreadHeader"
	"js/view/modules/AutoCompleteList"

	], (_, Template, ChatList, NewMessage, ChatHandler, ThreadHeader, AutoCompleteList) ->
	Backbone.View.extend
		className: "chat-list-view-controller"
		initialize: ->
			@setTemplate()
			

			@newMessage = new NewMessage()

			@threadHeader = new ThreadHeader()
			@autoCompleteList = new AutoCompleteList()
			@autoCompleteList.dataSource = @
			@autoCompleteList.delegate = @newMessage
			@newMessage.autoCompleteList = @autoCompleteList
			
			@chatList = new ChatList()
			@chatList.targetSelector = ".chat-list-view-controller .chat-list-container-scroller"
			@chatList.enableDragAndDrop = true
			
			@chatHandler = new ChatHandler()
			
			# Settings the Task Handler to receive actions from the task list
			@chatList.chatDelegate = @chatHandler
			@chatList.dragDelegate = @chatHandler
			@chatList.dataSource = @chatHandler
			Backbone.on("opened-window", @focusInput, @)
		getResultsForTextAndSearchLetter: (searchLetter, searchText) ->
			results = []
			if searchLetter is "@"
				sortedUsers = _.sortBy(swipy.slackCollections.users.activeUsers(true), (user) ->
					return user.get("name")
				)
				_.each(sortedUsers, (user) ->
					#console.log user.toJSON()
					if user.get("name").startsWith(searchText)
						results.push({id: user.id, name: user.get("name")})
				)
			else if searchLetter is "#"
				sortedChannels = _.sortBy(swipy.slackCollections.channels.activeChannels(), (channel) ->
					return channel.get("name")
				)
				_.each(sortedChannels, (channel) ->
					#console.log user.toJSON()
					if channel.get("name") and channel.get("name").startsWith(searchText)
						results.push({id: channel.id, name: channel.get("name")})
				)
			return results
		setTemplate: ->
			@template = _.template Template
		render: ->
			@$el.html @template({})
			@newMessage.render()
			@$el.prepend( @newMessage.el )

			@threadHeader.render()
			@$el.prepend( @threadHeader.el )

			# Adding the Auto completer above the input field (bottom of chat container)
			@$el.find(".chat-list-container").prepend( @autoCompleteList.el )

			@chatList.render()
			@focusInput()
		focusInput: ->
			@newMessage?.$el.find('textarea').focus()
		destroy: ->
			Backbone.off(null, null, @)
			@chatList?.remove?()
			@threadHeader?.remove()
			@newMessage?.remove?()
			@autoCompleteList?.remove()
			@chatHandler?.destroy?()
			@remove()