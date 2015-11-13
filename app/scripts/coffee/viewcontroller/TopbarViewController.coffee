define [
	"underscore"
	"text!templates/viewcontroller/topbar-view-controller.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		el: ".top-bar-container"
		className: ".top-bar-container"
		initialize: ->
			@foregroundColor = ".navigation-foreground-light"
		setForegroundColor: (color) ->
			foregroundClass = ".navigation-foreground-light"
			if color is "dark"
				foregroundClass = ".navigation-foreground-dark"

			if color isnt @foregroundColor
				@$el.removeClass(@foregroundColor)
				@$el.addClass(foregroundClass)
				@foregroundColor = foregroundClass
		setBackgroundColor: (color) ->
			@$el.css("backgroundColor", "transparent")
			color = "transparent" if !color
			@$el.css("backgroundColor", color)
		setTitle: (title, reset) ->
			@$el.find(".title").html(title)
			if reset
				@setForegroundColor()
				@setBackgroundColor()