###
	Get all the tasks from project, team member or personal (subcollection w/ filter)
	Receive action from TaskList about a drag/drop hit and handle the request
		Find out who's the sender, where does it want to go, and what actions would be available
	Receive select/unselect from TaskList
###
define ["underscore"], (_) ->
	class TaskHandler
		constructor: ->
		loadCollection: (collection) ->
			@collection = collection
			@reloadWithEvent = _.debounce( @reloadWithEvent, 5 )
			@collection.on("add remove reset", @reloadWithEvent )
			# @listenTo( swipy.collections.todos, "add remove reset change:priority change:completionDate change:schedule change:rejectedByTag change:rejectedBySearch change:subtasksLocal", @renderList )
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