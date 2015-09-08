define [
	"underscore"
	"text!templates/viewcontroller/chat-list-view-controller.html"
	"js/view/chatlist/ChatList"
	"js/view/chatlist/NewMessage"
	"js/handler/ChatHandler"

	], (_, Template, ChatList, NewMessage, ChatHandler) ->
	Backbone.View.extend
		className: "chat-list-view-controller"
		initialize: ->
			@setTemplate()

			@newMessage = new NewMessage()


			@chatList = new ChatList()
			@chatList.targetSelector = ".chat-list-view-controller .chat-list-container-scroller"
			@chatList.enableDragAndDrop = true
			
			@chatHandler = new ChatHandler()
			
			# Settings the Task Handler to receive actions from the task list
			@chatList.chatDelegate = @chatHandler
			@chatList.dragDelegate = @chatHandler
			@chatList.dataSource = @chatHandler
			Backbone.on("opened-window", @focusInput, @)
		

		setTemplate: ->
			@template = _.template Template
		render: ->
			@$el.html @template({})
			@newMessage.render()
			@$el.prepend( @newMessage.el )
			@chatList.render()
			@focusInput()
		focusInput: ->
			@newMessage?.$el.find('input').focus()
		destroy: ->
			Backbone.off(null, null, @)
			@chatList?.remove?()
			@newMessage?.remove?()
			@chatHandler?.destroy?()
			@remove()