define [
	"underscore"
	"js/view/sidebar/SidebarChannelRow"
	"js/view/modal/UserPickerModal"
	"js/view/modal/ChannelPickerModal"
	"js/view/modal/GenericModal"
	], (_, ChannelRow, UserPickerModal, ChannelPickerModal, GenericModal) ->
	Backbone.View.extend
		el: ".sidebar_content"
		initialize: ->
			@bouncedRenderSidebar = _.debounce(@renderSidebar, 15)
			@listenTo( swipy.slackCollections.channels, "add reset remove change:is_open change:is_active_channel change:is_member change:is_starred change:unread_count_display", @bouncedRenderSidebar )

			@bouncedUpdateNotificationsForMyTasks = _.debounce(@updateNotificationsForMyTasks, 15)
			@listenTo( swipy.collections.todos, "add reset remove change:completionDate change:schedule", @bouncedUpdateNotificationsForMyTasks)
			# Proper render list when projects change/add/remove
			_.bindAll( @, "renderSidebar", "clickedInvite")
			@listenTo( Backbone, "set-active-menu", @setActiveMenu )
			@listenTo( Backbone, "resized-window", @checkAndEnableScrollBars)
			@listenTo( Backbone, "close/channel", @closeChannel, @)
			@listenTo( Backbone, "channel/action", @channelAction, @)
			@listenTo( Backbone, "open/invitemodal", @clickedInvite)
			@listenTo( Backbone, "opened-window", @collapseChannels)
			@listenTo( Backbone, "opened-window", @collapseDM)
			@renderSidebar()
			@updateNotificationsForMyTasks()
			@expandedDM = false
			@expandedChannels = false
		events:
			"click .add-project.button-container a": "clickedAddProject"
			"click .invite-link": "clickedInvite"
			"click #sidebar-members-list .more-button-dm": "clickedExpandDM"
			"click #sidebar-project-list .more-button": "clickedExpandChannels"
			"click #sidebar-members-list > h1,  #sidebar-members-list .add-button": "clickedDM"
			"click #sidebar-project-list .add-button" : "clickedAddChannel"
			"click #sidebar-group-list .add-button" : "clickedAddGroup"
			"click #sidebar-project-list > h1" : "clickedChannels"
			"click #sidebar-group-list .more-button, #sidebar-group-list > h1": "clickedGroups"
		clickedInvite: ->
			modal = @getModal("invite", "Invite your favorite colleagues<br>to work with.", "No more colleagues to invite")
			modal.searchField = true
			modal.selectOne = false
			modal.render()
			modal.presentModal()
			false
		collapseDM: ->
			@expandedDM = false
			@bouncedRenderSidebar()
		collapseChannels: ->
			@expandedChannels = false
			@bouncedRenderSidebar()

		clickedExpandDM: ->
			@expandedDM = !@expandedDM
			@bouncedRenderSidebar()
			false
		clickedExpandChannels: ->
			@expandedChannels = !@expandedChannels
			@bouncedRenderSidebar()
			false
		clickedGroups: ->
			modal = @getChannelModal("groups", "Join a private group you're not part of", "No more groups to join")
			modal.searchField = true
			modal.render()
			modal.presentModal()
			false
		clickedChannels: ->
			modal = @getChannelModal("channels", "Join a channel you're not part of", "No more channels to join")
			modal.searchField = true
			modal.render()
			modal.presentModal()
			false
		clickedDM: ->
			modal = @getModal("dm", "Direct Message.")
			modal.searchField = true
			modal.render()
			modal.presentModal()
			false
		channelAction: (channel, e) ->
			actions = []
			
			if channel.get("is_starred")
				return channel.unpin()
				actions.push({name: "Unpin", icon: "dragMenuMove", action: "unpin"})
			else
				return channel.pin()
				actions.push({name: "Pin", icon: "dragMenuInvite", action: "pin"})

			actions.push({name: "Close", icon: "materialClose", action: "close"})
			swipy.modalVC.presentActionList(actions, {centerX: false, centerY: false, left: e.pageX, top: e.pageY}, (result) =>
				if result is "pin"
					channel.pin()
				else if result is "unpin"
					channel.unpin()
				else if result is "close"
					channel.closeChannel()
			)					
		getChannelModal: (type, title, emptyMessage) ->
			@modalType = type
			channelPickerModal = new ChannelPickerModal()
			channelPickerModal.dataSource = @
			channelPickerModal.delegate = @
			channelPickerModal.title = title
			channelPickerModal.emptyMessage = emptyMessage
			channelPickerModal.loadChannels()
			channelPickerModal
		getModal: (type, title, emptyMessage) ->
			@modalType = type
			userPickerModal = new UserPickerModal()
			userPickerModal.dataSource = @
			userPickerModal.delegate = @
			userPickerModal.title = title
			userPickerModal.emptyMessage = emptyMessage
			userPickerModal.loadPeople()
			userPickerModal
		userPickerClickedUser: (targetUser) ->
			if @modalType is "invite"
				swipy.api.callAPI("invite/slack", "POST", {invite: {"slackUserId": targetUser.id, "type": "Standard Invite"}}, (res, error) =>
					console.log "res from invite", res, error
					if res and res.ok
						swipy.analytics.logEvent("Invite Sent", {"Hours Since Signup": res.hoursSinceSignup, "From": "Invite Overlay"})
				)
			else if @modalType is "dm"
				swipy.slackSync.apiRequest("im.open", {"user": targetUser.id}, (res,error) =>
					if res and res.ok
						swipy.router.navigate("im/"+targetUser.get("name"), {trigger:true})
					else alert("error trying to message " + JSON.stringify(res) + " " + JSON.stringify(error))
				)
		channelPickerClickedChannel: (targetChannel) ->
			if @modalType is "channels"
				swipy.slackSync.apiRequest("channels.join", {"name": targetChannel.get("name") }, (res,error) =>
					if res and res.ok
						swipy.router.navigate("channel/"+targetChannel.get("name"), {trigger:true})
					else alert("error trying to message " + JSON.stringify(res) + " " + JSON.stringify(error))
				)
			else if @modalType is "groups"
				swipy.slackSync.apiRequest("groups.open", {"channel": targetChannel.id }, (res,error) =>
					if res and res.ok
						swipy.router.navigate("group/"+targetChannel.get("name"), {trigger:true})
					else alert("error trying to message " + JSON.stringify(res) + " " + JSON.stringify(error))
				)
		channelPickerModalChannels: (channelPickerModal) ->
			channels = []
			swipy.slackCollections.channels.each( (channel) =>
				if @modalType is "channels"
					if channel.get("is_channel") and !channel.get("is_archived")
						if !channel.get("is_member") 
							channels.push(channel.toJSON())
				else if @modalType is "groups"
					if channel.get("is_group") and !channel.get("is_archived")
						if !channel.get("is_open")
							channels.push(channel.toJSON())
				return false
			)
			return channels

		userPickerModalPeople: (userPickerModal) ->
			people = []
			me = swipy.slackCollections.users.me()
			users = swipy.slackCollections.users.filter((user) =>
				return false if user.get("deleted") or user.id is me.id
				return false if @modalType is "invite" and user.id is "USLACKBOT"
				return true
			)
			for user in users
				people.push(user.toJSON())
			return people
		closeChannel: (model) ->
			model.closeChannel()
		clickedAddGroup: (e) ->
			createGroupCallback = (() ->
				return (groupName) ->
					if !groupName
						return [{error: "You can't create group with an empty name"}]
					else if groupName.length > 0
						swipy.slackSync.apiRequest("groups.create",{name: groupName},(res, error) =>
							if res and res.ok
								swipy.router.navigate("group/"+res.channel.name)
							else
								console.log("error group",res, error)
						)
			)()

			genericModal = new GenericModal
				type: 'inputModal'
				submitCallback: createGroupCallback
				inputSelector: 'input'
				tmplOptions:
					title: 'Create new private group'
					cancelText: 'CANCEL'
					submitText: 'CREATE'
					placeholder: 'Group name'
			false
		clickedAddChannel: (e) ->
			createChannelCallback = (() ->
				return (channelName) ->
					if !channelName
						return [{error: "You can't create channel with an empty name"}]
					else if channelName.length > 0
						swipy.slackSync.apiRequest("channels.create",{name: channelName},(res, error) =>
							if res and res.ok
								swipy.router.navigate("channel/"+res.channel.name)
							else
								console.log("error channel",res, error)
						)
			)()

			genericModal = new GenericModal
				type: 'inputModal'
				submitCallback: createChannelCallback
				inputSelector: 'input'
				tmplOptions:
					title: 'Create new channel'
					cancelText: 'CANCEL'
					submitText: 'CREATE'
					placeholder: 'New channel name'
			false
		renderSidebar: ->
			channelsLeft = 0
			filteredChannels = _.filter(swipy.slackCollections.channels.models, (channel) -> 
				if channel.get("type") is "public" and !channel.get("is_archived")
					return true
					if channel.get("is_member") 
						return true
					else
						channelsLeft++
				return false
			)
			channels = _.sortBy( filteredChannels, (channel) -> 
				if channel.get("unread_count_display") or !channel.get("is_starred")
					return 0 + channel.get("name")
				return 1 + channel.get("name") 
			)
			@$el.find("#sidebar-project-list .projects").html("")
			if channelsLeft > 0
				buttonText = if @expandedChannels then "Hide unstarred" else "+"+ channelsLeft + " More..."
				@$el.find("#sidebar-project-list .more-button").html(buttonText)
			@$el.find("#sidebar-project-list .more-button").toggleClass("shown", (channelsLeft > 0))
			

			for channel in channels
				rowView = new ChannelRow({model: channel})
				@$el.find("#sidebar-project-list .projects").append(rowView.el)
				rowView.render()
			if !channels.length then $("#sidebar-project-list .projects").html('<li class="empty">No unread messages</li>')

			imsLeft = 0
			filteredIms = _.filter(swipy.slackCollections.channels.models, (channel) => 
				if channel.get("is_im") and channel.get("is_open")
					if @expandedDM or channel.get("is_active_channel") or channel.get("is_starred") or channel.get("unread_count_display")
						if @expandedDM and !channel.get("is_starred")
							imsLeft++
						return true
					else
						imsLeft++
				return false
			)
			ims = _.sortBy(filteredIms, (im) ->
				user = swipy.slackCollections.users.get(im.get("user")).toJSON()
				if user.name is "slackbot"
					nameString = 0 
				else nameString = user.name
				if im.get("unread_count_display") or !im.get("is_starred")
					return 0 + nameString
				return 1 + nameString 
			)
			if imsLeft > 0
				buttonText = if @expandedDM then "Hide unstarred" else "+"+ imsLeft + " More..."
				@$el.find("#sidebar-members-list .more-button").html(buttonText)
			@$el.find("#sidebar-members-list .more-button").toggleClass("shown", (imsLeft > 0))
			

			@$el.find("#sidebar-members-list .team-members").html("")
			for im in ims
				user = swipy.slackCollections.users.get(im.get("user"))
				rowView = new ChannelRow({model: im})
				rowView.setUser(user)

				@$el.find("#sidebar-members-list .team-members").append(rowView.el)
				rowView.render()
			if !ims.length then $("#sidebar-members-list .team-members").html('<li class="empty">No unread messages</li>')

			@checkAndEnableScrollBars()
			@delegateEvents()
			@setActiveMenu(@activeClass) if @activeClass?
		updateNotificationsForMyTasks: ->
			activeTasks = swipy.collections.todos.getMyActive()
			numberOfActive = activeTasks.length
			notificationText = if numberOfActive > 0 then ""+numberOfActive else ""
			$('.sidebar-controls #sidebar-tasks-now').toggleClass("unread", ( numberOfActive > 0))
			$('.sidebar-controls #sidebar-tasks-now .notification').html notificationText
		checkAndEnableScrollBars: ->
			overflow = "hidden"
			if $(".sidebar-controls").outerHeight(true) > $("body").height()
				overflow = "scroll"
			$('.sidebar_content').css("overflowY",overflow)
		setActiveMenu: (activeClass) ->
			@activeClass = activeClass
			$(".sidebar-controls .active").removeClass("active")
			$(".sidebar-controls #"+activeClass).addClass("active")
		destroy: ->
			@stopListening()