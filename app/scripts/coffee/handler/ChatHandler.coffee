###
	Get all the tasks from project, team member or personal (subcollection w/ filter)
	Receive action from TaskList about a drag/drop hit and handle the request
		Find out who's the sender, where does it want to go, and what actions would be available
	Receive select/unselect from TaskList
###
define ["underscore"], (_) ->
	class ChatHandler
		constructor: ->
			@bouncedReloadWithEvent = _.debounce( @reloadWithEvent, 5 )
		loadCollection: (collection) ->
			@collection = collection
			@collection.on("add remove reset", @bouncedReloadWithEvent , @ )

			# @listenTo( swipy.collections.todos, "add remove reset change:priority change:completionDate change:schedule change:rejectedByTag change:rejectedBySearch change:subtasksLocal", @renderList )
		messageCollectionIdFromHtmlId: (messageHtmlId) ->
			# #message-
			return if !messageHtmlId or !_.isString(messageHtmlId)
			messageHtmlId.substring(9)
		taskCollectionIdFromHtmlId: (taskHtmlId) ->
			# #task-
			return if !taskHtmlId or !_.isString(taskHtmlId)
			taskHtmlId.substring(6)
		reloadWithEvent: ->
			Backbone.trigger("reload/chathandler")

		sortAndGroupCollection: ->
			@groupedMessages = []
			if @delegate? and _.isFunction(@delegate.chatHandlerSortAndGroupCollection)
				@groupedMessages = @delegate.chatHandlerSortAndGroupCollection( @, @collection )
			else
				@groupedMessages = [ { "leftTitle": null, "rightTitle": null, "messages": @collection.models }]
			return @groupedMessages
		

		###
			DragHandler Delegate
		###
		dragHandlerDraggedIdsForEvent: (dragHandler, e ) ->
			draggedIds = []

			if e.path?
				for el in e.path
					$el = $(el)
					if $el.hasClass("chat-item")
						draggedId = "#" + $el.attr("id")
			else if e.originalTarget?
				currentTarget = e.originalTarget
				for num in [1..10]
					if currentTarget? and currentTarget
						if _.indexOf(currentTarget.classList, "chat-item") isnt -1
							draggedId = "#" + currentTarget.id
						else
							currentTarget = currentTarget.parentNode
					else
						break

			draggedMessage = @collection.get( @messageCollectionIdFromHtmlId(draggedId) )
			if draggedMessage
				draggedIds.push(draggedId)
				$('.drag-mouse-pointer ul').html "<li>"+draggedMessage.get("message")+"</li>"
			draggedIds
		didCreateDragHandler: ( dragHandler ) ->
			@dragHandler = dragHandler
		# Deal with dropped items from DragHandler if true is returned, callback must be called!
		dragHandlerDidHit: ( dragHandler, draggedIds, hit, callback ) ->
			draggedId = draggedIds[0]
			draggedMessage = @collection.get( @messageCollectionIdFromHtmlId(draggedId) )
			console.log draggedMessage
			return if !draggedMessage?
			self = @
			
			return false if !hit?
			console.log hit
			if hit.type is "task-list"
				Backbone.trigger( "create-task", draggedMessage.get("message"))

		###
			ChatList Datasource
		###
		
		# ChatList asking for number of sections
		chatListNumberOfSections: ( chatList ) ->
			@sortAndGroupCollection()
			return @groupedMessages.length
		chatListLeftTitleForSection: ( chatList, section ) ->
			return @groupedMessages[ (section-1) ].leftTitle
		chatListRightTitleForSection: ( chatList, section ) ->
			return @groupedMessages[ (section-1) ].rightTitle
		
		chatListMessagesForSection: ( chatList, section ) ->
			if !@collection?
				throw new Error("ChatHandler: must loadSubcollection before loading ChatList")

			models = @groupedMessages[ (section-1) ].messages

			return models

		destroy: ->
			@groupedMessages = null
			@collection?.off( null, null, @ )
			@collection?.reset(null)
			@collection = null
