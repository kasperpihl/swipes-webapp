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
	], (_, Section, ChatMessage, Unread) ->
	Backbone.View.extend
		className: "chat-list"
		initialize: ->
			# Set HTML tempalte for our list
			@bouncedRender = _.debounce(@render, 5)
			@bouncedMarkAsRead = _.debounce(@markAsRead, 800)
			@listenTo( Backbone, "reload/chathandler", @bouncedRender )
			_.bindAll(@, "checkIsRead")
			@hasRendered = false
			@sectionsByTitle = {}
			@chatsBySectionByTimestamp = {}
		remove: ->
			@cleanUp()
			@$el.empty()
			
		# Reload datasource for 

		render: ->
			if !@dataSource?
				throw new Error("ChatList must have dataSource")
			if !_.isFunction(@dataSource.chatListDataForSection)
				throw new Error("ChatList dataSource must implement chatListDataForSection")

			if !@targetSelector?
				throw new Error("ChatList must have targetSelector to render")


			shouldScrollToBottom = false
			shouldAddNewUnread = @hasRendered
			shouldScrollToBottom = true if !@hasRendered

			if @scrollToBottomVar is true
				@scrollToBottomVar = false
				shouldScrollToBottom = true
			shouldScrollToBottom = true if @isScrolledToBottom()

			if !@hasRendered	
				@$el.html ""
				$(@targetSelector).html( @$el )


			numberOfSections = 1
			numberOfChats = 0
			numberOfNewChats = 0
			
			if _.isFunction(@dataSource.chatListNumberOfSections)
				numberOfSections = @dataSource.chatListNumberOfSections( @ )

			startTime = new Date().getTime()
			for section in [1 .. numberOfSections]
				# Load messages and titles for section
				sectionData = @dataSource.chatListDataForSection( @, section )
				continue if !sectionData or !sectionData.messages.length

				lastSender = false
				lastUnix = 0
				renderSession = false

				# Instantiate
				section = @sectionsByTitle[sectionData.leftTitle]
				if !section
					section = new Section()
					@sectionsByTitle[sectionData.leftTitle] = section
					@chatsBySectionByTimestamp[sectionData.leftTitle] = {}
					section.setTitles(sectionData.leftTitle, sectionData.rightTitle)
					renderSession = true

				sectionEl = section.$el.find('.section-list')

				chatReference = @chatsBySectionByTimestamp[sectionData.leftTitle]
				for chat in sectionData.messages
					numberOfChats++
					if !@removeUnreadIfSeen and @unread and chat.get("ts") is @unread.ts
						sectionEl.append( @unread.el )

					if !shouldAddNewUnread and !@unread?
						if chat.get("ts") and parseInt(chat.get("ts")) > @lastRead and chat.get("user")?.id isnt swipy.slackCollections.users.me().id
							@unread = new Unread()
							sectionEl.append( @unread.el )
							@unread.ts = chat.get("ts")
					chatMessage = chatReference[chat.get("ts")]
					renderChat = false
					if !chatMessage
						chatMessage = new ChatMessage({model: chat})
						chatReference[chat.get("ts")] = chatMessage
						renderChat = true
						numberOfNewChats++
					sender = chat.get("user")
					sender = chat.get("bot_id") if !sender
					sender = chat.get("username") if !sender
					unixStamp = parseInt(chat.get("ts"))
					date = new Date(unixStamp*1000)
					timeDiff = Math.abs(unixStamp - lastUnix)

					if sender and sender is lastSender and timeDiff < 2400
						chatMessage.isFromSameSender = true
					if chat.get("subtype") is "file_share" or chat.get("attachments")
						chatMessage.isFromSameSender = false
					if lastChat? and (lastChat.get("subtype") is "file_share" or lastChat.get("attachments"))
						chatMessage.isFromSameSender = false
					lastSender = sender
					lastUnix = unixStamp
					
					if @chatDelegate?
						chatMessage.chatDelegate = @chatDelegate
					chatMessage.render()
					sectionEl.append( chatMessage.el ) if renderChat
					lastChat = chat
				@$el.append section.el if renderSession
			if !@unread? and lastChat? and unixStamp > @lastRead
				if @delegate? and _.isFunction(@delegate.chatListMarkAsRead)
					@delegate.chatListMarkAsRead( @ )
						
			if shouldScrollToBottom
				_.debounce(@scrollToBottom,10)()
			@moveToBottomIfNeeded()
			if @unread?
				$(".chat-list-container-scroller").on("scroll.chatlist", @checkIsRead)
				@checkIsRead()
			@hasRendered = true
			
			
		isScrolledToBottom: ->
			return ($(".chat-list-container-scroller").scrollTop() + $(".chat-list-container-scroller").height() >= $(".chat-list").outerHeight())
		scrollToBottom: ->
			targetPos = $(".chat-list").outerHeight() - $(".chat-list-container-scroller").height()
			if targetPos > 0
				$(".chat-list-container-scroller").scrollTop(targetPos)
		moveToBottomIfNeeded: ->
			targetMargin = $(".chat-list-container-scroller").height() - $(".chat-list").outerHeight()
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
						@delegate.chatListMarkAsRead( @ )
					@bouncedMarkAsRead()
					$(".chat-list-container-scroller").off( "scroll.chatlist", @checkIsRead )
		markAsRead: ->
			if @chatDelegate?
				$('.unread-seperator').addClass("read")
		customCleanUp: ->
		cleanUp: ->
			$(".chat-list-container-scroller").off( "scroll.chatlist", @checkIsRead )
			@dataSource = null
			@delegate = null
			@chatDelegate = null
			# A hook for the subviews to do custom clean ups
			@customCleanUp()
			@stopListening()