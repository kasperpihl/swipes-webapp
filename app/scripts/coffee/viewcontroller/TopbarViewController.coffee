define [
	"underscore"
	"text!templates/viewcontroller/topbar-view-controller.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		el: ".top-bar-container"
		className: ".top-bar-container"
		initialize: ->
			@foregroundClass = "navigation-foreground-dark"
		setForegroundColor: (color) ->
			foregroundClass = "navigation-foreground-dark"
			if color is "light"
				foregroundClass = "navigation-foreground-light"

			if color isnt @foregroundClass
				@$el.removeClass(@foregroundClass)
				@$el.addClass(foregroundClass)
				@foregroundClass = foregroundClass
		setBackgroundColor: (color) ->
			@$el.css("backgroundColor", "")
			if color
				@$el.css("backgroundColor", color)
		enableBoxShadow: (enable) ->
			enableToggle = false
			enableToggle = true if enable
			@$el.toggleClass("navigation-boxshadow", enableToggle)
		setTitle: (title, reset) ->
			@$el.find(".title").html(title)
			if reset
				@setForegroundColor()
				@setBackgroundColor()