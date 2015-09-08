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
			"click .catchClick": "clickedLink"
		initialize: ->
			throw new Error("Model must be added when constructing a ChatMessage") if !@model?
			@template = _.template MessageTmpl, {variable: "data" }
			@attTemplate = _.template AttachmentsTmpl, {variable: "data"}
			_.bindAll(@, "render")
			@new = true
			@model.on("change:likes change:timestamp change:text change:attachments", @render )
		render: ->
			@$el.attr('id', "message-"+@model.id )
			@$el.addClass("new") if @new
			@$el.html @template( message: @model, isFromSameSender: @isFromSameSender, attTmpl: @attTemplate )
			@new = false
			return @
		clickedLink: (e) ->
			href = $(e.currentTarget).attr("href")
			if(href.startsWith("http://swipesapp.com/forward?dest=invite"))
				Backbone.trigger("open/invitemodal")
			if href.startsWith("#task/")
				swipy.router.task(href.substring("#task/".length))
			false
		clickedLike: (e) ->
			###console.log e
			if @chatDelegate? and _.isFunction(@chatDelegate.messageDidClickLike)
				@chatDelegate.messageDidClickLike(@, e)###
		remove: ->
			@$el.empty()