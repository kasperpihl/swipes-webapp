define [
	"underscore"
	"js/view/sidebar/SidebarChannelRow"
	"js/view/modal/UserPickerModal"
	], (_, ChannelRow, UserPickerModal) ->
	Backbone.View.extend
		el: ".sidebar_content"
		initialize: ->
			@bouncedRenderSidebar = _.debounce(@renderSidebar, 15)
			@listenTo( swipy.slackCollections.channels, "add reset remove change:is_open", @bouncedRenderSidebar )
			@bouncedUpdateNotificationsForMyTasks = _.debounce(@updateNotificationsForMyTasks, 15)
			@listenTo( swipy.collections.todos, "add reset remove change:completionDate change:schedule", @bouncedUpdateNotificationsForMyTasks)
			# Proper render list when projects change/add/remove
			
			_.bindAll( @, "renderSidebar", "clickedInvite")
			@listenTo( Backbone, "set-active-menu", @setActiveMenu )
			@listenTo( Backbone, "resized-window", @checkAndEnableScrollBars)
			@listenTo( Backbone, "close/channel", @closeChannel, @)
			@listenTo( Backbone, "open/invitemodal", @clickedInvite)
			@renderSidebar()
			@updateNotificationsForMyTasks()
		events:
			"click .add-project.button-container a": "clickedAddProject"
			"click .invite-link": "clickedInvite"
			"click #sidebar-members-list .more-button-dm, #sidebar-members-list > h1,  #sidebar-members-list .add-button": "clickedDM"
			"click #sidebar-project-list .add-button" : "clickedAddChannel"
			#"click #sidebar-group-list .more-button, #sidebar-group-list > h1": "clickedGroup"
		clickedInvite: ->
			modal = @getModal("invite", "Invite your favorite colleagues<br>to work with.", "No more colleagues to invite")
			modal.searchField = true
			modal.selectOne = false
			modal.render()
			modal.presentModal()
			false
		clickedDM: ->
			modal = @getModal("dm", "Direct Message.")
			modal.searchField = true
			modal.render()
			modal.presentModal()
			false
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
		userPickerModalPeople: (userPickerModal) ->
			people = []
			me = swipy.slackCollections.users.me()
			users = swipy.slackCollections.users.filter((user) ->
				return false if user.get("deleted") or user.id is me.id or user.id is "USLACKBOT"
				return true
			)
			for user in users
				people.push(user.toJSON())
			return people
		closeChannel: (model) ->
			model.closeChannel()
		clickedAddChannel: (e) ->
			channelName = prompt("Please enter channel name", "");
			if channelName? and channelName.length > 0
				console.log channelName	
				swipy.slackSync.apiRequest("channels.create",{name: channelName},(res, error) =>
					if res and res.ok
						swipy.router.navigate("channel/"+res.channel.name)
					else
						console.log("error channel",res, error)
				)
			false
		renderSidebar: ->
			channelsLeft = 0
			filteredChannels = _.filter(swipy.slackCollections.channels.models, (channel) -> 
				if channel.get("is_channel")
					if channel.get("is_member") 
						return true
					else if !channel.get("is_archived")
						channelsLeft++
				return false
			)
			channels = _.sortBy( filteredChannels, (channel) -> return channel.get("name") )
			@$el.find("#sidebar-project-list .projects").html("")
			#@$el.find("#sidebar-project-list .more-button").toggleClass("shown", (channelsLeft > 0))
			@$el.find("#sidebar-project-list .more-button").html("+"+ channelsLeft + " More...")

			for channel in channels
				rowView = new ChannelRow({model: channel})
				@$el.find("#sidebar-project-list .projects").append(rowView.el)
				rowView.render()

			groupsLeft = 0
			filteredGroups = _.filter(swipy.slackCollections.channels.models, (channel) -> 
				if channel.get("is_group") and !channel.get("is_archived")
					if channel.get("is_open")
						return true
					else
						groupsLeft++
				return false
			)
			groups = _.sortBy( filteredGroups, (group) -> return group.get("name") )
			@$el.find("#sidebar-group-list .groups").html("")
			#@$el.find("#sidebar-group-list .more-button").toggleClass("shown", (groupsLeft > 0))
			@$el.find("#sidebar-group-list .more-button").html("+"+ groupsLeft + " More...")
			for group in groups
				rowView = new ChannelRow({model: group})
				@$el.find("#sidebar-group-list .groups").append(rowView.el)
				rowView.render()
				

			filteredIms = _.filter(swipy.slackCollections.channels.models, (channel) -> return channel.get("is_im") and channel.get("is_open"))
			ims = _.sortBy(filteredIms, (im) ->
				user = swipy.slackCollections.users.get(im.get("user")).toJSON()
				if user.name is "slackbot"
					return 0 
				return user.name
			)
			usersInTotal = _.filter(swipy.slackCollections.users.models, (user) -> !user.get("deleted") )
			# Minus one extra - subtracting my self
			usersLeft = usersInTotal.length - ims.length - 1
			@$el.find("#sidebar-members-list .more-button").toggleClass("shown", (usersLeft > 0))
			@$el.find("#sidebar-members-list .more-button").html("+"+ usersLeft + " More...")

			@$el.find("#sidebar-members-list .team-members").html("")
			for im in ims
				user = swipy.slackCollections.users.get(im.get("user"))
				rowView = new ChannelRow({model: im})
				rowView.setUser(user)

				@$el.find("#sidebar-members-list .team-members").append(rowView.el)
				rowView.render()

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