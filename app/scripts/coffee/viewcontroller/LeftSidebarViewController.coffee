define [
	"underscore"
	"text!templates/sidemenu/sidebar-projects.html"
	"text!templates/sidemenu/sidebar-team-members.html"
	], (_, ProjectsTemplate, TeamMembersTemplate) ->
	Backbone.View.extend
		el: ".sidebar_content"
		initialize: ->
			@setTemplates()
			@bouncedRenderSidebar = _.debounce(@renderSidebar, 15)
			@listenTo( swipy.slackCollections.channels, "add reset remove change:unread_count change:unread_count_display", @bouncedRenderSidebar )
			# Proper render list when projects change/add/remove
			
			#@listenTo( swipy.collections.members, "add remove reset change:name change:status", @renderSidebar )
			_.bindAll( @, "renderSidebar")
			@listenTo( Backbone, "set-active-menu", @setActiveMenu )
			@listenTo( Backbone, "resized-window", @checkAndEnableScrollBars)
			@renderSidebar()
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
			notifications = swipy.notificationModel.get("notifications")
			filteredChannels = _.filter(swipy.slackCollections.channels.toJSON(), (channel) -> return channel.is_channel and channel.is_member )
			channels = _.sortBy( filteredChannels, (channel) -> return channel.name )
			@$el.find("#sidebar-project-list .projects").html(@projectsTpl({ channels: channels }))
			

			filteredIms = _.filter(swipy.slackCollections.channels.toJSON(), (channel) -> return channel.is_im and channel.is_open)
			ims = _.sortBy(filteredIms, (im) ->
				im.user = swipy.slackCollections.users.get(im.user).toJSON()
				return 0 if im.user.name is "slackbot"
				return im.user.name
			)
			@$el.find("#sidebar-members-list .team-members").html(@membersTpl({ ims: ims}))
			
			@checkAndEnableScrollBars()
			@delegateEvents()
			@setActiveMenu(@activeClass) if @activeClass?
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