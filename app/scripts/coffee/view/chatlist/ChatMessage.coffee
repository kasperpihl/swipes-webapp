###

###
define [
	"underscore"
	"text!templates/chatlist/chat-message.html"
	"text!templates/chatlist/chat-attachments.html"
	], (_, MessageTmpl, AttachmentsTmpl) ->
	Backbone.View.extend
		tagName: "li"
		className: "chat-item"
		events:
			"click .like-button" : "clickedLike"
		initialize: ->
			throw new Error("Model must be added when constructing a ChatMessage") if !@model?
			@template = _.template MessageTmpl, {variable: "data" }
			@attTemplate = _.template AttachmentsTmpl, {variable: "data"}
			_.bindAll(@, "render")
			@model.on("change:likes change:timestamp", @render )
		render: ->
			@$el.attr('id', "message-"+@model.id )
			@$el.html @template( message: @model, isFromSameSender: @isFromSameSender, attTmpl: @attTemplate )

			return @
		clickedLike: (e) ->
			###console.log e
			if @chatDelegate? and _.isFunction(@chatDelegate.messageDidClickLike)
				@chatDelegate.messageDidClickLike(@, e)###
		remove: ->
			@$el.empty()