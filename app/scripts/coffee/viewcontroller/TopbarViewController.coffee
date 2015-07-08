define [
	"underscore"
	"text!templates/viewcontroller/topbar-view-controller.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		initialize: ->
			@template = _.template(Tmpl)
			@render()
		render: ->
			@$el.html(@template({}))
			$(".top-bar").html(@$el)