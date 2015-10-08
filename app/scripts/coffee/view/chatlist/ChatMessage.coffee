###

###
define [
	"underscore"
	"text!templates/chatlist/chat-message.html"
	"text!templates/chatlist/chat-attachments.html"
	"js/utility/Utility"
	], (_, MessageTmpl, AttachmentsTmpl, Utility) ->
	Backbone.View.extend
		#tagName: "li"
		className: "chat-item"
		events:
			"click .chat-image" : "lightboxOpen"
			"click .like-button" : "clickedLike"
			"click .catchClick": "clickedLink"
			"click .hover-box": "clickedActions"
		initialize: ->
			throw new Error("Model must be added when constructing a ChatMessage") if !@model?
			@template = _.template MessageTmpl, {variable: "data" }
			@attTemplate = _.template AttachmentsTmpl, {variable: "data"}
			_.bindAll(@, "render")
			@new = true
			@util = new Utility()
			@model.on("change:likes change:timestamp change:text change:attachments", @render )
		render: ->
			@$el.attr('id', "message-"+@model.id )
			@$el.addClass("new") if @new
			@$el.html @template
				message: @model
				handleMentionsAndLinks: @util.handleMentionsAndLinks
				isFromSameSender: @isFromSameSender
				attTmpl: @attTemplate
				isThread: @isThread
			@new = false
			return @
		lightboxOpen: (e) ->
			console.log("does this work")
			img = $('img')
			#for some reason it doesn't work without and extra click, not sure why, if you can figure it out kudos!
			img.on 'click', ->
				imgSrc = @src
				if imgSrc.indexOf('slack-files.com') >= 0
					imgSrcFirst = imgSrc.split('/').slice(-2)[0].split('-').slice(0)[0]
					imgSrcSecond = imgSrc.split('/').slice(-2)[0].split('-').slice(1)[0]
					imgSrcFileOne = imgSrc.split('/').slice(-1)[0].split('/').slice(0)[0]
					endLink = imgSrcFirst + '-' + imgSrcSecond + '/' + imgSrcFileOne + '/'
					bigEndLink = endLink.replace('_360', '')
					newImgLink = 'https://files.slack.com/files-pri/' + bigEndLink
					console.log imgSrcFileOne
					$('.lightbox-overlay').fadeIn '100', ->
						$('.lightbox').html '<img src="' + newImgLink + '" />'
						return
					return
				else 
			$('.lightbox-overlay').on 'click', ->
				$('.lightbox').empty()
				$(this).fadeOut 'fast', ->
					return
				return
		clickedActions: (e) ->
			if @chatDelegate? and _.isFunction(@chatDelegate.messageClickedActions)
				@chatDelegate.messageClickedActions(@, e)
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