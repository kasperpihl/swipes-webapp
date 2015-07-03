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
			
		setTemplates: ->
			@projectsTpl = _.template ProjectsTemplate
			@membersTpl = _.template TeamMembersTemplate
		renderSidebar: ->
			tempProjects = [
					id: 123
					name: "Swipes Time"
				,
					id: 234
					name: "Teamwork"
			]
			@$el.find("#sidebar-project-list").html(@projectsTpl({projects: tempProjects}))
			
			tempMembers = [
					id: 123
					name: "yana"
				,
					id: 234
					name: "stefan"

			]
			@$el.find("#sidebar-members-list").html(@membersTpl({members: tempMembers}))