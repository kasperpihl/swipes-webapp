define [
	"underscore"
	"js/view/modal/ListActionModal"
	], (_, ListActionModal) ->
	Backbone.View.extend
		el: '.modal-overlay-container'
		events:
			"click .modal-clickable-background" : "clickedBackground"
		initialize: ->
			_.bindAll( @ , "clickedBackground", "alignContent" )
			@$contentEl = @$el.find('.modal-overlay-content')
		
		###
			API's for showing different Modals
		###
		
		# Present Action List (ListActionModal)
		presentActionList:( actions, options, callback ) ->
			@callback = callback
			self = @
			modal = new ListActionModal()
			modal.loadActionsAndCallback( actions, (result) -> 
				self.callback(result)
				self.hideContent()
			)
			modal.render()
			@presentView(modal.el, options, callback)
		###
			Functionality to show and handle modal	
		###
		presentView: (el, options, callback) ->
			# Default Values
			clickableBackground = true
			@closeOnClick = true
			@centerX = true
			@centerY = true
			
			@left = "50%"
			@top = "50%"

			opaque = false
			frame = false
			
			@callback = callback

			if options? and _.isObject(options)
				clickableBackground = options.clickableBackground if options.clickableBackground?
				@closeOnClick = options.closeOnClick if options.closeOnClick?
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
			Backbone.on( "resized-window", @alignContent, @ )
			return
		showContent: ->
			@alignContent()
			@$contentEl.addClass("shown")

		alignContent: ->
			# Setting Coordinates for content view
			width = @$contentEl.outerWidth()
			height = @$contentEl.outerHeight()

			marginLeft = marginTop = 0
			if @centerX
				marginLeft = -width/2
			if @centerY
				marginTop = -height/2

			cssProps =
				"bottom": "auto"
				"right": "auto"
				"top": @top
				"left": @left

			# Making sure content is inside the screen
			if @left? or @top?
				windowWidth = $(window).width()
				windowHeight = $(window).height()
				left = parseInt(@left, 10) if @left?
				top = parseInt(@top, 10) if @top?

				# Proper deal width percentage vs pixels
				if @left? and _.isString(@left) and @left.indexOf("%") isnt -1
					left = parseInt(windowWidth / 100 * left, 10)
				if @top? and _.isString(@top) and @top.indexOf("%") isnt -1
					top = parseInt(windowHeight / 100 * top, 10)

				if (@left? and left + marginLeft) < 0
					cssProps["left"] = 0
					marginLeft = 0
				if (@top? and top + marginTop) < 0
					cssProps["top"] = 0
					marginTop = 0
				if @left? and (left + width + marginLeft) > windowWidth
					cssProps["left"] = "auto"
					cssProps["right"] = 0
					marginLeft = 0
				if @top? and (top + height + marginTop) > windowHeight
					cssProps["top"] = "auto"
					cssProps["bottom"] = 0
					marginTop = 0


			cssProps["marginLeft"] = marginLeft
			cssProps["marginTop"] = marginTop
			@$contentEl.css(cssProps)

			
		hideContent: ->
			
			@$el.removeClass("shown")
			@$contentEl.removeClass("shown")
			Backbone.off( null, null, @ )
			@callback?()
			@callback = null

		clickedBackground: (e) ->
			if @closeOnClick
				@hideContent()