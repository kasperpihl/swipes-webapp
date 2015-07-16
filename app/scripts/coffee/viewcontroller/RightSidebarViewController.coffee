define [
	"underscore"
	"text!templates/sidemenu/right-sidebar.html"
	"js/view/sidebar/TagFilter"
	], (_, Template, TagFilter) ->
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
			if @sidebarDelegate? and _.isFunction(@sidebarDelegate.sidebarClickedMenuButton)
				@sidebarDelegate.sidebarClickedMenuButton( @, e )
		setTemplate: ->
			@template = _.template( Template, {variable: "data"})
		renderSidebar: ->
			@buttons = [{ "iconClass": "navbarWorkspace"}, { "iconClass": "done" }]
			isActiveClass = null
			@$el.find(".right-sidebar-controls").html( @template({buttons: @buttons, activeClass: isActiveClass }) )
			@delegateEvents()
			@setActiveMenu(@buttons[1].iconClass)
		
		loadWindow:(el) ->
			width = 400
			#el = new TagFilter().el
			@$el.find('.right-window-content').html(el)	
			
			@setWindowWidth(width)

			@$el.find('.right-window-container').addClass('shown')
			
		closeWindow: ->
			@$el.find('.right-window-container').removeClass('shown')
			@setWindowWidth(0)

		setWindowWidth: (width) ->
			widthOfRightSidebar = @$el.width()
			$containerEl = @$el.find('.right-window-container')

			$(".content-container").css("paddingRight", (width+widthOfRightSidebar) + "px")
			$containerEl.css("width", width + "px")

		setActiveMenu: (activeClass) ->
			@$el.find(".right-sidebar-controls .active").removeClass("active")
			@$el.find(".right-sidebar-controls ."+activeClass).addClass("active")