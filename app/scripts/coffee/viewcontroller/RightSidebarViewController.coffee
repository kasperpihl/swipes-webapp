define [
	"underscore"
	"text!templates/sidemenu/right-sidebar.html"
	], (_, Template) ->
	Backbone.View.extend
		el: ".right-sidebar-outer-container"
		initialize: ->
			@setTemplate()
			@renderSidebar()
			_.bindAll( @, "renderSidebar", "clickedRightSideButton")
		events:
			"click .rightbar-button" : "clickedRightSideButton"
			"click .right-side-close": "closeWindow"
		setButtonIcons: (buttonIcons) ->
			@buttons = buttonIcons
			@renderSidebar
		clickedRightSideButton: (e) ->
			console.log e
			target = $(e.currentTarget).attr("data-href")
			@loadSidemenu(target)
			
		setTemplate: ->
			@template = _.template( Template, {variable: "data"})
		renderSidebar: ->
			@buttons = [{ "iconClass": "navbarChat"}, { "iconClass": "navbarFiles" }]
			@$el.find(".right-sidebar-controls").html( @template({buttons: @buttons }) )
			@delegateEvents()
		loadSidemenu:(target) ->
			if target is "navbarChat"
				title = "DISCUSSION"
				el = "Chat"
				if @sidebarDelegate? and _.isFunction(@sidebarDelegate.sidebarWillLoadChat)
					@sidebarDelegate.sidebarWillLoadChat( @, chat )
			else if target is "navbarFiles"
				el = "Here will be your files"
				title = "ATTACHMENTS"
			else return
			@$el.find('.right-window-container').addClass('shown')
			@$el.find('.right-sidebar-controls').addClass("hasActiveEl")
			@$el.find('.right-sidebar-controls .active').removeClass("active")
			@$el.find('.right-sidebar-controls .' + target).addClass("active")

			@loadWindow(el, title)
		loadWindow:(el, title) ->
			width = 400
			@$el.find('.right-side-title').html(title)
			@$el.find('.right-window-content').html(el)	
			
			@setWindowWidth(width)

			
		closeWindow: ->
			@$el.find('.right-window-container').removeClass('shown')
			@$el.find('.right-sidebar-controls').removeClass("hasActiveEl")
			@$el.find('.right-sidebar-controls .active').removeClass("active")
			@setWindowWidth(0)

		setWindowWidth: (width) ->
			widthOfRightSidebar = @$el.width()
			$containerEl = @$el.find('.right-window-container')

			$(".content-container").css("paddingRight", (width+widthOfRightSidebar) + "px")
			$containerEl.css("width", width + "px")

		setActiveMenu: (activeClass) ->
			@$el.find(".right-sidebar-controls .active").removeClass("active")
			@$el.find(".right-sidebar-controls ."+activeClass).addClass("active")