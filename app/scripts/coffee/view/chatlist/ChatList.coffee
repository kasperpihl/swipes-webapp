###
	The TaskList Class - Intended to be UI only for rendering a tasklist.
	Has a datasource to provide it with task models
	Has a delegate to notify when drag/drop/click/other actions occur
###
define [
	"underscore"
	"js/view/modules/Section"
	"js/view/chatlist/ChatMessage"
	"js/view/chatlist/Unread"
	"js/handler/DragHandler"
	], (_, Section, ChatMessage, Unread, DragHandler) ->
	Backbone.View.extend
		className: "chat-list"
		initialize: ->
			# Set HTML tempalte for our list
			@bouncedRender = _.debounce(@render, 5)
			@bouncedMarkAsRead = _.debounce(@markAsRead, 800)
			@listenTo( Backbone, "reload/chathandler", @bouncedRender )
			_.bindAll(@, "checkIsRead")
			@hasRendered = false
		remove: ->
			@cleanUp()
			@$el.empty()
			
		# Reload datasource for 

		render: ->
			if !@dataSource?
				throw new Error("ChatList must have dataSource")
			if !_.isFunction(@dataSource.chatListMessagesForSection)
				throw new Error("ChatList dataSource must implement chatListChatsForSection")

			if !@targetSelector?
				throw new Error("ChatList must have targetSelector to render")


			shouldScrollToBottom = false
			shouldScrollToBottom = @hasRendered = true if !@hasRendered
			if @scrollToBottomVar is true
				@scrollToBottomVar = false
				shouldScrollToBottom = true
			shouldScrollToBottom = true if @isScrolledToBottom()

			@$el.html ""
			$(@targetSelector).html( @$el )


			numberOfSections = 1
			numberOfChats = 0
			
			if _.isFunction(@dataSource.chatListNumberOfSections)
				numberOfSections = @dataSource.chatListNumberOfSections( @ )
			cachedMembers = _.indexBy(swipy.collections.members.toJSON(), "objectId")
			if @unread
				$(".chat-list-container-scroller").off( "scroll.chatlist", @checkIsRead )
			@unread = null

			for section in [1 .. numberOfSections]
				lastSender = false
				# Load tasks and titles for section
				if _.isFunction(@dataSource.chatListLeftTitleForSection)
					leftTitle = @dataSource.chatListLeftTitleForSection( @, section )
				if _.isFunction(@dataSource.chatListRightTitleForSection)
					rightTitle = @dataSource.chatListRightTitleForSection( @, section )
				chatsInSection = @dataSource.chatListMessagesForSection( @, section )
				

				# Instantiate 
				section = new Section()
				section.setTitles(leftTitle, rightTitle)
				sectionEl = section.$el.find('.section-list')

				for chat in chatsInSection

					numberOfChats++
					if chat.get("unread")
						if !@unread?
							@unread = new Unread()
							sectionEl.append( @unread.el )
						@unread.lastUnread = chat.get("timestamp")
					chatMessage = new ChatMessage({model: chat})
					sender = chat.get("userId")
					chatMessage.isFromSameSender = true if sender is lastSender
					lastSender = sender
					
					if @chatDelegate?
						chatMessage.chatDelegate = @chatDelegate
					chatMessage.render()
					sectionEl.append( chatMessage.el )

				@$el.append section.el
			if @enableDragAndDrop and numberOfChats > 0
				if !@dragDelegate?
					throw new Error("TaskList must have dragDelegate to enable Drag & Drop")
				if !@dragHandler?
					@dragHandler = new DragHandler()
					@dragHandler.enableFullScreenTaskList = true
					@dragHandler.delegate = @dragDelegate
				@dragHandler.createDragAndDropElements(".chat-item")
			if shouldScrollToBottom
				@scrollToBottom()
			@moveToBottomIfNeeded()
			if @unread?
				$(".chat-list-container-scroller").on("scroll.chatlist", @checkIsRead)
				@checkIsRead()
			
		isScrolledToBottom: ->
			return ($(".chat-list-container-scroller").scrollTop() + $(".chat-list-container-scroller").height() >= $(".chat-list").height())
		scrollToBottom: ->
			targetPos = $(".chat-list").height() - $(".chat-list-container-scroller").height()
			if targetPos > 0
				$(".chat-list-container-scroller").scrollTop(targetPos)
		moveToBottomIfNeeded: ->
			targetMargin = $(".chat-list-container-scroller").height() - $(".chat-list").height()
			if targetMargin < 0
				targetMargin = 0
			$(".chat-list").css("marginTop", targetMargin)
		checkIsRead: (e) ->
			if @unread
				unreadY = @unread.$el.position().top
				wrapperHeight = $(".chat-list-container-scroller").height()
				#scrollY = $(".chat-list-container-scroller").scrollTop()
				if unreadY >= 0 and unreadY < wrapperHeight
					if @delegate? and _.isFunction(@delegate.chatListMarkAsRead)
						@delegate.chatListMarkAsRead( @, @unread.lastUnread )
					@bouncedMarkAsRead()
					$(".chat-list-container-scroller").off( "scroll.chatlist", @checkIsRead )
		markAsRead: ->
			if @chatDelegate?
				$('.unread-seperator').addClass("read")
		customCleanUp: ->
		cleanUp: ->
			$(".chat-list-container .chat-list-container-scroller").off( "scroll.chatlist", @checkIsRead )
			@dataSource = null
			@delegate = null
			@chatDelegate = null
			# A hook for the subviews to do custom clean ups
			@customCleanUp()
			@stopListening()