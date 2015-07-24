define [
	"underscore"
	"text!templates/sidemenu/right-sidebar.html"
	], (_, Template) ->
	Backbone.View.extend
		el: ".right-sidebar-outer-container"
		initialize: ->
			@setTemplate()
			@renderSidebar()
			_.bindAll( @, "renderSidebar", "clickedRightSideButton", "clickedClose")
		events:
			"click .rightbar-button" : "clickedRightSideButton"
			"click .right-side-close": "clickedClose"
		setButtonIcons: (buttonIcons) ->
			@buttons = buttonIcons
			@renderSidebar
		clickedRightSideButton: (e) ->
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
		setNewDelegate: (delegate) ->
			@sidebarDelegate = delegate
			@reload()
		reload: ->
			if @activeClass
				@loadSidemenu(@activeClass)
		loadSidemenu:(target) ->
			@vc?.destroy()
			if @sidebarDelegate? and _.isFunction(@sidebarDelegate.sidebarGetViewController)
				@vc = @sidebarDelegate.sidebarGetViewController( @, target )
				@loadWindow(@vc.el)
				@vc.render()
			else throw new Error("RightSidebarViewController: sidebarDelegate must implement sidebarGetViewController")
			@activeClass = target
			@$el.find('.right-window-container').addClass('shown')
			@$el.find('.right-sidebar-controls').addClass("hasActiveEl")
			@$el.find('.right-sidebar-controls .active').removeClass("active")
			@$el.find('.right-sidebar-controls .' + target).addClass("active")

			#@loadWindow(el, title)
		loadWindow:(el) ->
			width = 400
			@$el.find('.right-window-content').html(el)	
			
			@setWindowWidth(width)

		clickedClose: ->
			if @sidebarDelegate? and _.isFunction(@sidebarDelegate.sidebarSwitchToView)
				@sidebarDelegate.sidebarSwitchToView(@, @activeClass )
			else throw new Error("RightSidebarViewController: sidebarDelegate must implement sidebarSwitchToView")
		closeWindow: ->
			@vc?.destroy()
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