define [
	"underscore"
	"gsap"
	"text!templates/viewcontroller/team-member-view-controller.html"
	], (_, TweenLite, Template) ->
	Backbone.View.extend
		initialize: ->
			@setTemplate()
			@render()
		setTemplate: ->
			@template = _.template Template
		render: ->
			$("#main").html(@template({}))
		
		open: (options) ->
			memberId = options.id
			@loadMember(memberId)
		loadMember: (memberId) ->
			# Load team member view
		destroy: ->