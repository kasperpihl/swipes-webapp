define [
	"underscore"
	"text!templates/viewcontroller/topbar-view-controller.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		el: ".top-bar-container"
		initialize: ->
			@template = _.template(Tmpl, {variable: "data"})
			@render()
		render: ->
			#@$el.html(@template({"backgroundColor": "background:red;"}))
		
		setMainTitleAndEnableProgress: (title, progress) ->
			@$el.find(".title").html(title)