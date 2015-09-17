###

###
define [
	"underscore"
	"text!templates/searchlist/search-result-row.html"
	"js/utility/Utility"
	"js/utility/TimeUtility"
	], (_, Tmpl, Utility, TimeUtility) ->
	Backbone.View.extend
		tagName: "li"
		className: "search-result-item"
		initialize: ->
			throw new Error("Model must be added when constructing a SearchResultRow") if !@model?
			@template = _.template Tmpl, {variable: "data" }
			_.bindAll(@, "render")
			@util = new Utility()
			@timeUtil = new TimeUtility()
		render: ->
			@$el.html @template( result: @model, type: @type, util: @util, timeUtil: @timeUtil )
			return @
		remove: ->
			@$el.empty()