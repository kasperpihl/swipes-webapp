###

###
define [
	"underscore"
	"text!templates/chatlist/chat-message.html"
	], (_, MessageTmpl) ->
	Backbone.View.extend
		tagName: "li"
		className: "chat-item"
		initialize: ->
			throw new Error("Model must be added when constructing a ChatMessage") if !@model?
			@template = _.template MessageTmpl, {variable: "data" }
		render: ->
			@$el.attr('id', "message-"+@model.id )
			@$el.html @template( message: @model, isFromSameSender: @isFromSameSender )

			return @
		remove: ->
			@$el.empty()