define [
	"underscore"
	"text!templates/tasklist/task-section.html"
	], (_, TaskSectionTmpl) ->
	Backbone.View.extend
		className: "task-section"
		initialize: ->
			@template = _.template TaskSectionTmpl, { variable: "data" }
			@render()
		setTitles: (leftTitle, rightTitle) ->
			@leftTitle = leftTitle
			@rightTitle = rightTitle
			@render()
		render: ->
			@$el.html @template( { leftTitle: @leftTitle, rightTitle: @rightTitle } )
			return @
		remove: ->
			@$el.empty()