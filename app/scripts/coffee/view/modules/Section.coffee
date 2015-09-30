define [
	"underscore"
	"text!templates/modules/section.html"
	], (_, SectionTmpl) ->
	Backbone.View.extend
		className: "section"
		events:
			"click a.expandable": "clickedHeader"
		initialize: ->
			@template = _.template SectionTmpl, { variable: "data" }
		setClass: (className) ->
			@$el.addClass(className)
		setTitles: (leftTitle, rightTitle) ->
			@leftTitle = leftTitle
			@rightTitle = rightTitle
			@render()
		clickedHeader: (e) ->
			Backbone.trigger("clicked/section", $(e.currentTarget).attr("data-href"))
			false
		render: ->
			@$el.html @template( { leftTitle: @leftTitle, rightTitle: @rightTitle, expandClass: @expandClass } )
			return @
		remove: ->
			@$el.empty()