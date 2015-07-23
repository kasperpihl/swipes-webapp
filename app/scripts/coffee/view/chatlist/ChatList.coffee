###
	The TaskList Class - Intended to be UI only for rendering a tasklist.
	Has a datasource to provide it with task models
	Has a delegate to notify when drag/drop/click/other actions occur
###
define [
	"underscore"
	"js/view/modules/Section"
	"js/view/chatlist/ChatMessage"
	], (_, Section, ChatMessage) ->
	Backbone.View.extend
		className: "chat-list"
		initialize: ->
			# Set HTML tempalte for our list
			@bouncedRender = _.debounce(@render, 5)
			@listenTo( Backbone, "reload/chathandler", @bouncedRender )

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
			
			@$el.html ""
			$(@targetSelector).html( @$el )


			numberOfSections = 1
			numberOfChats = 0
			
			if _.isFunction(@dataSource.chatListNumberOfSections)
				numberOfSections = @dataSource.chatListNumberOfSections( @ )
			cachedMembers = _.indexBy(swipy.collections.member.toJSON(), "objectId")
			console.log cachedMembers
			for section in [1 .. numberOfSections]
				

				# Load tasks and titles for section
				if _.isFunction(@dataSource.chatListLeftTitleForSection)
					leftTitle = @dataSource.chatListLeftTitleForSection( @, section )
				if _.isFunction(@dataSource.chatListRightTitleForSection)
					rightTitle = @dataSource.chatListRightTitleForSection( @, section )
				chatsInSection = @dataSource.chatListTasksForSection( @, section )
				

				# Instantiate 
				section = new Section()
				section.setTitles(leftTitle, rightTitle)
				sectionEl = section.$el.find('.chat-section-list')

				for chat in chatsInSection
					numberOfChats++
					chatMessage = new ChatMessage({model: chat})
					if @chatDelegate?
						chatMessage.chatDelegate = @chatDelegate
					chatMessage.render()
					sectionEl.append( chatMessage.el )
				@$el.append section.el

		
		customCleanUp: ->
		cleanUp: ->
			# A hook for the subviews to do custom clean ups
			@customCleanUp()
			@stopListening()