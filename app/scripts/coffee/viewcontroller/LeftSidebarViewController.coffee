define [
	"underscore"
	"text!templates/sidemenu/sidebar-projects.html"
	"text!templates/sidemenu/sidebar-team-members.html"
	"js/view/sidebar/SidebarChannelRow"
	], (_, ProjectsTemplate, TeamMembersTemplate, ChannelRow) ->
	Backbone.View.extend
		el: ".sidebar_content"
		initialize: ->
			@setTemplates()
			@bouncedRenderSidebar = _.debounce(@renderSidebar, 15)
			@listenTo( swipy.slackCollections.channels, "add reset remove", @bouncedRenderSidebar )
			@bouncedUpdateNotificationsForMyTasks = _.debounce(@updateNotificationsForMyTasks, 15)
			@listenTo( swipy.collections.todos, "add reset remove change:completionDate change:schedule", @bouncedUpdateNotificationsForMyTasks)
			# Proper render list when projects change/add/remove
			
			_.bindAll( @, "renderSidebar")
			@listenTo( Backbone, "set-active-menu", @setActiveMenu )
			@listenTo( Backbone, "resized-window", @checkAndEnableScrollBars)
			@renderSidebar()
			@updateNotificationsForMyTasks()
		events:
			"click .add-project.button-container a": "clickedAddProject"
		clickedAddProject: (e) ->
			project = prompt("Please enter project name", "");
			if project? and project.length > 0
				projectObj = swipy.collections.projects.create({name: project, ownerId: 1})
				projectObj.save({}, {sync:true})
			false
		setTemplates: ->
			@projectsTpl = _.template ProjectsTemplate, {variable: "data"}
			@membersTpl = _.template TeamMembersTemplate, {variable: "data"}
		renderSidebar: ->
			filteredChannels = _.filter(swipy.slackCollections.channels.models, (channel) -> return channel.get("is_channel") and channel.get("is_member") )
			channels = _.sortBy( filteredChannels, (channel) -> return channel.get("name") )
			@$el.find("#sidebar-project-list .projects").html("")
			for channel in channels
				rowView = new ChannelRow({model: channel})
				@$el.find("#sidebar-project-list .projects").append(rowView.el)
				rowView.render()

			filteredGroups = _.filter(swipy.slackCollections.channels.models, (channel) -> return channel.get("is_group") and channel.get("is_open") and !channel.get("is_archived") )
			groups = _.sortBy( filteredGroups, (group) -> return group.get("name") )
			@$el.find("#sidebar-group-list .groups").html("")
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