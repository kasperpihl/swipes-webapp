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

		setTemplates: ->
			@projectsTpl = _.template ProjectsTemplate
			@membersTpl = _.template TeamMembersTemplate
		renderSidebar: ->
			@$el.find("#sidebar-project-list").html(@projectsTpl({projects: swipy.collections.projects.toJSON()}))
			
			tempMembers = [
					id: 123
					name: "yana"
				,
					id: 234
					name: "stefan"

			]
			@$el.find("#sidebar-members-list").html(@membersTpl({members: tempMembers}))