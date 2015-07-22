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
			if target is @activeClass
				@closeWindow()
			else
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
				if @sidebarDelegate? and _.isFunction(@sidebarDelegate.sidebarGetChatViewController)
					chatVC = @sidebarDelegate.sidebarGetChatViewController( @ )
					el = chatVC.el
				else throw new Error("RightSidebarViewController: Couldn't get chat view controller from delegate")
			else if target is "navbarFiles"
				el = "Here will be your files"
				title = "ATTACHMENTS"
			else return
			@activeClass = target
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
			@activeClass = null
			@setWindowWidth(0)

		setWindowWidth: (width) ->
			widthOfRightSidebar = @$el.width()
			$containerEl = @$el.find('.right-window-container')

			$(".content-container").css("paddingRight", (width+widthOfRightSidebar) + "px")
			$containerEl.css("width", width + "px")

		setActiveMenu: (activeClass) ->
			@$el.find(".right-sidebar-controls .active").removeClass("active")
			@$el.find(".right-sidebar-controls ."+activeClass).addClass("active")