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
			console.log options
			memberId = options.id
			@loadMember(memberId)
		loadMember: (memberId) ->
			# Load team member view
			name = switch memberId
				when "842" then "mitko"
				when "234" then "stanimir"
				when "324" then "stefan"
				when "123" then "yana"
				else "no name"
			swipy.topbarVC.setMainTitleAndEnableProgress(name, false)
		destroy: ->