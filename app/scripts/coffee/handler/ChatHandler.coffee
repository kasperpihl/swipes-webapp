###
	Get all the tasks from project, team member or personal (subcollection w/ filter)
	Receive action from TaskList about a drag/drop hit and handle the request
		Find out who's the sender, where does it want to go, and what actions would be available
	Receive select/unselect from TaskList
###
define ["underscore", "js/utility/TimeUtility"], (_, TimeUtility) ->
	class ChatHandler
		constructor: ->
			@bouncedReloadWithEvent = _.debounce( @reloadWithEvent, 5 )
		loadCollection: (channelModel) ->
			@model = channelModel
			@collection = channelModel.getMessages()
			@timeUtil = new TimeUtility()
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
			groups = @collection.groupBy((model, i) ->
				date = new Date(parseInt(model.get("ts"))*1000)
				return moment(date).startOf('day').unix()
				
			)
			taskGroups = []
			sortedKeys = _.keys(groups).sort()
			for key in sortedKeys
				schedule = new Date(parseInt(key)*1000)

				title = @timeUtil.dayStringForDate(schedule)
				@groupedMessages.push({ leftTitle: title, messages: groups[key]})
			return @groupedMessages
		
		idForEvent:(e) ->
			if e.path?
				for el in e.path
					$el = $(el)
					if !draggedId and $el.hasClass("chat-item")
						draggedId = "#" + $el.attr("id")
			else if e.originalTarget? or e.target?
				currentTarget = e.target if e.target?
				currentTarget = e.originalTarget if e.originalTarget?
				for num in [1..10]
					if currentTarget? and currentTarget
						if _.indexOf(currentTarget.classList, "chat-item") isnt -1
							draggedId = "#" + currentTarget.id
						else
							currentTarget = currentTarget.parentNode
					else
						break
			draggedId
		###
			DragHandler Delegate
		###
		messageClickedActions: (chatMessage, e) ->
			model = chatMessage.model
			me = swipy.slackCollections.users.me()
			actions = []
			actions.push({name: "Create Task", icon: "dragMenuCopy", action: "create"})
			if model and model.get("user") is me.id
				actions.push({name: "Edit", icon: "dragMenuMove", action: "edit"})
				actions.push({name: "Delete", icon: "navbarDelete", action: "delete"})
			swipy.modalVC.presentActionList(actions, {centerX: false, centerY: false, left: e.pageX, top: e.pageY}, (result) =>
				if result is "create"
					#Backbone.trigger("create-task", )
					title = prompt("Please enter task name", model.getText())
					if title
						Backbone.trigger( "create-task", title, {from: "Message", assignee: me.id })
				else if result is "delete"
					shouldDelete = confirm("Delete Message")
					if shouldDelete
						options = {
							ts: model.get("ts")
							channel: @model.id
						}
						swipy.slackSync.apiRequest("chat.delete", options, (res, error) ->
							console.log "result from message delete", res, error
							if res and res.ok
								model.set("text", newText)
						)
				else if result is "edit"
					newText = prompt("Edit Message", model.get("text"))
					if newText? and newText.length and newText isnt model.get("text")
						options = {
							ts: model.get("ts")
							text: newText
							channel: @model.id
						}
						swipy.slackSync.apiRequest("chat.update", options, (res, error) ->
							console.log "result from message update", res, error
							if res and res.ok
								model.set("text", newText)
						)
			)
		###
			ChatMessage Delegate
		###
		messageDidClickLike: (chatMessage, e) ->
			model = chatMessage.model
			model.like()


		###
			ChatList Datasource
		###
		
		# ChatList asking for number of sections
		chatListNumberOfSections: ( chatList ) ->
			@sortAndGroupCollection()
			return @groupedMessages.length
		
		chatListDataForSection: ( chatList, section ) ->
			if !@collection?
				throw new Error("ChatHandler: must loadSubcollection before loading ChatList")
			return null if !@groupedMessages or !@groupedMessages.length

			return @groupedMessages[ (section-1) ]

		destroy: ->
			@groupedMessages = null
			@collection?.off( null, null, @ )
			@collection?.reset(null)
			@collection = null
