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
			@listenTo( swipy.notificationModel, "change:notifications", @bouncedRenderSidebar )
			# Proper render list when projects change/add/remove
			@listenTo( swipy.collections.projects, "add remove reset change:name", @renderSidebar )
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
			@$el.find("#sidebar-project-list .projects").html(@projectsTpl({notifications: notifications, projects: _.sortBy(swipy.collections.projects.toJSON(), "name")}))
			@$el.find("#sidebar-members-list .team-members").html(@membersTpl({notifications: notifications, members: _.sortBy(_.filter(swipy.collections.members.toJSON(), (member) -> return !member.me ), "username")}))
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