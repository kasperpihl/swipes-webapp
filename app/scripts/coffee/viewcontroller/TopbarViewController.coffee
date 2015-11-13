define [
	"underscore"
	"text!templates/viewcontroller/topbar-view-controller.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		className: "top-bar-inner-container"
		initialize: ->
			@template = _.template(Tmpl, {variable: "data"})
			@render()
		render: ->
			@$el.html(@template({"backgroundColor": "background:red;"}))
			$(".top-bar-container").html(@$el)

		setMainTitleAndEnableProgress: (title, progress) ->
			@$el.find(".title").html(title)
			@$el.find('.progress-header').toggleClass( "no-progress", !progress)