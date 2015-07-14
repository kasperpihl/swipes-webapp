define [
	"underscore"
	"text!templates/sidemenu/sidebar-projects.html"
	"text!templates/sidemenu/sidebar-team-members.html"
	], (_, ProjectsTemplate, TeamMembersTemplate) ->
	Backbone.View.extend
		el: ".sidebar_content"
		initialize: ->
			@setTemplates()
			@renderSidebar()
			@listenTo( swipy.collections.projects, "add remove reset change:name", @renderSidebar )
			#@listenTo( swipy.collections.members, "add remove reset change:name change:status", @renderSidebar )
			_.bindAll( @, "renderSidebar")
			@listenTo( Backbone, "set-active-menu", @setActiveMenu )
			$(window).on "resize.sidebar", @checkAndEnableScrollBars
		events:
			"click .add-project.button-container a": "clickedAddProject"
		clickedAddProject: (e) ->
			project = prompt("Please enter project name", "");
			if project? and project.length > 0
				projectObj = swipy.collections.projects.create({name: project})
				projectObj.save({}, {sync:true})
			false
		setTemplates: ->
			@projectsTpl = _.template ProjectsTemplate
			@membersTpl = _.template TeamMembersTemplate
		renderSidebar: ->
			@$el.find("#sidebar-project-list .projects").html(@projectsTpl({projects: swipy.collections.projects.toJSON()}))
			
			tempMembers = [
					id: 842
					name: "mitko"
					status: "online"
				,
					id: 234
					name: "stanimir"
					status: "offline"
				,
					id: 324
					name: "stefan"
					status: "busy"
				,
					id: 123
					name: "yana"
					status: "online"

			]
			@$el.find("#sidebar-members-list .team-members").html(@membersTpl({members: tempMembers}))
			@checkAndEnableScrollBars()
			@delegateEvents()
		checkAndEnableScrollBars: ->
			overflow = "hidden"
			if $(".sidebar-controls").outerHeight(true) > $("body").height()
				overflow = "scroll"
			$('.sidebar_content').css("overflowY",overflow)
		setActiveMenu: (activeClass) ->
			$(".sidebar-controls .active").removeClass("active")
			$(".sidebar-controls #"+activeClass).addClass("active")
		destroy: ->
			$(window).off "resize.sidebar"