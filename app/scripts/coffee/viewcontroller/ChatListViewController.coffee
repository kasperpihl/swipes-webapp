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

			@threadHeader.render()
			@$el.prepend( @threadHeader.el )

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
			@chatHandler?.destroy?()
			@remove()