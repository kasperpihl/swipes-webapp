define [
	"underscore"
	], (_) ->
	Backbone.View.extend
		el: '.modal-overlay-container'
		events:
			"click .modal-clickable-background" : "clickedBackground"
		initialize: ->
			_.bindAll( @ , "clickedBackground", "alignContent")
			@$contentEl = @$el.find('.modal-overlay-content')
			
		presentView: (el, options, callback) ->
			# Default Values
			clickableBackground = true
			@centerX = true
			@centerY = true
			
			@left = null
			@top = null

			opaque = false
			frame = false

			@callback = callback
			
			if options? and _.isObject(options)

				clickableBackground = options.clickableBackground if options.clickableBackground?
				opaque = options.opaque if options.opaque?
					
				@top = options.top if options.top?
				@left = options.left if options.left?

				@centerX = options.centerX if options.centerX?
				@centerY = options.centerY if options.centerY?
				
				frame = options.frame if options.frame?


			# Setting visibility of background overlay
			@$el.find('.modal-clickable-background').toggleClass('shown', clickableBackground)
			# Setting opaque of clickable overlay
			@$el.find('.modal-clickable-background').toggleClass('opaque', opaque)
			
			
			# Clearing Content View and adding element
			@$contentEl.removeClass("shown").html(el)
			# Adding frame if options is chosen
			@$contentEl.toggleClass("frame", frame)

			@$el.addClass("shown")

			# Show and align center
			@showContent()
			$(window).on( "resize.modalcontroller", @alignContent )
			return
		showContent: ->
			@alignContent()
			@$contentEl.addClass("shown")

		alignContent: ->
			# Setting Coordinates for content view
			width = @$contentEl.outerWidth()
			height = @$contentEl.outerHeight()

			marginLeft = marginRight = 0
			if @centerX
				marginLeft = -width/2
			if @centerY
				marginTop = -height/2

			cssProps = {}
			# Making sure content is inside the screen
			
			if @left? or @top?
				left = parseInt(@left, 10) if @left?
				top = parseInt(@top, 10) if @top?
				windowWidth = $(window).width()
				windowHeight = $(window).height()
				# Content is to the left of the screen
				if (@left? and left + marginLeft) < 0
					@left = 0
					marginLeft = 0
				if (@top? and top + marginTop) < 0
					@top = 0
					marginTop = 0
				if @left? and (left + width + marginLeft) > windowWidth
					@left = "auto"
					cssProps["right"] = 0
					marginLeft = 0
				if @top? and (top + height + marginTop) > windowHeight
					@top = "auto"
					cssProps["bottom"] = 0
					marginTop = 0
			@left = 50+"%" if !@left?
			@top = 50+"%" if !@top?

			cssProps["left"] = @left
			cssProps["top"] = @top
			cssProps["marginLeft"] = marginLeft
			cssProps["marginTop"] = marginTop
			@$contentEl.css(cssProps)

			
		hideContent: ->
			@$el.removeClass("shown")
			@$contentEl.removeClass("shown")
			$(window).off( "resize.modalcontroller", @alignContent )
			@callback?()
			@callback = null
		clickedBackground: (e) ->
			console.log "clicked"
			@hideContent()