define [
	"underscore"
	"text!templates/modules/section.html"
	], (_, SectionTmpl) ->
	Backbone.View.extend
		className: "section"
		initialize: ->
			@template = _.template SectionTmpl, { variable: "data" }
			@render()
		setClass: (className) ->
			@$el.addClass(className)
		setTitles: (leftTitle, rightTitle) ->
			@leftTitle = leftTitle
			@rightTitle = rightTitle
			@render()
		render: ->
			@$el.html @template( { leftTitle: @leftTitle, rightTitle: @rightTitle } )
			return @
		remove: ->
			@$el.empty()