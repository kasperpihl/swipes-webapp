define [
	"underscore"
	"text!templates/sidemenu/right-sidebar.html"
	"gsap"
	"gsap-draggable"
	], (_, Template) ->
	Backbone.View.extend
		el: ".right-sidebar-outer-container"
		initialize: ->
			@setTemplate()
			@renderSidebar()
			@currentWidth = 400
			@draggedStartX = @currentWidth
			_.bindAll( @, "renderSidebar", "clickedRightSideButton", "clickedClose")
			dragOpts =
				type: "left"
				bounds: $(".right-side-inner-container")
				# Throwing / Dragging
				throwProps: no
				cursor: "col-resize"
				maxDuration: 0.4
				minimumMovement:6
				onDragStartParams: [ @ ]
				onDragParams: [ @ ]
				onDragEndParams: [ @ ]
				# Handlers
				onDragStart: (self) ->
				onDrag: (self) ->
					targetWidth = self.draggedStartX - @x
					self.setWindowWidth( targetWidth )
				onDragEnd: (self) ->
					targetWidth = self.draggedStartX - @x
					self.setWindowWidth(targetWidth )
					self.currentWidth = targetWidth

			Draggable.create(".right-window-content-container .drag-resizer .drag-el", dragOpts)
		events:
			"click .rightbar-button" : "clickedRightSideButton"
			"click .right-side-close": "clickedClose"
		setButtonIcons: (buttonIcons) ->
			@buttons = buttonIcons
			@renderSidebar
		clickedRightSideButton: (e) ->
			target = $(e.currentTarget).attr("data-href")
			if @sidebarDelegate? and _.isFunction(@sidebarDelegate.sidebarSwitchToView)
				@sidebarDelegate.sidebarSwitchToView(@, target )
			###if target is @activeClass
				@closeWindow()
			else
				@loadSidemenu(target)###
			@activeClass = target
			@setActiveMenu(target)
		setTemplate: ->
			@template = _.template( Template, {variable: "data"})
		renderSidebar: ->
			return
			@buttons = [{ "iconClass": "navbarChat"}, { "iconClass": "today" }]
			@$el.find(".right-sidebar-controls").html( @template({buttons: @buttons }) )
			@delegateEvents()
		setNewDelegate: (delegate) ->
			@sidebarDelegate = delegate
			@reload()
		reload: ->
			if @activeClass
				@loadSidemenu(@activeClass)
		loadSidemenu:(target) ->
			return
			@vc?.destroy()
			if @sidebarDelegate? and _.isFunction(@sidebarDelegate.sidebarGetViewController)
				@vc = @sidebarDelegate.sidebarGetViewController( @, target )
				@loadWindow(@vc.el)
				@vc.render()
			else throw new Error("RightSidebarViewController: sidebarDelegate must implement sidebarGetViewController")

			#@loadWindow(el, title)
		hideSidemenu: ->
			@closeWindow()
			$('.right-sidebar-outer-container').hide()
		loadWindow:(el) ->
			$('.right-sidebar-outer-container').show()
			@$el.find('.right-window-content').html(el)	
			@$el.find('.right-window-container').addClass('shown')
			@setWindowWidth(@currentWidth)

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
			widthOfRightSidebar = 0
			$containerEl = @$el.find('.right-window-container')

			$(".content-container").css("paddingRight", (width+widthOfRightSidebar) + "px")
			$containerEl.css("width", width + "px")

		setActiveMenu: (activeClass) ->
			@$el.find('.right-sidebar-controls').addClass("hasActiveEl")
			@$el.find(".right-sidebar-controls .active").removeClass("active")
			@$el.find(".right-sidebar-controls ."+activeClass).addClass("active")