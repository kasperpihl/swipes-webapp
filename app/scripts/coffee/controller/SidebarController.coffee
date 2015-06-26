define ["js/view/sidebar/Sidebar"
		"js/view/sidebar/TagFilter"
		"js/view/sidebar/SearchFilter" 
		"js/view/sidebar/TaskInput"
		"js/view/sidebar/SidemenuSettings"
		"js/view/list/OrganiseBar"
		"js/view/sidebar/settings/SidemenuSnoozes"
		"js/view/sidebar/settings/SidemenuTweaks"
		"js/view/sidebar/settings/SidemenuIntegrations"
		"js/view/overlays/KeyboardOverlay"
	], (SidebarView, TagFilter, SearchFilter, TaskInputView, SidemenuSettings, OrganiseBar, SidemenuSnoozes, SidemenuTweaks, SidemenuIntegrations, KeyboardOverlay ) ->
	class SidebarController
		constructor: ->
			@view = new SidebarView( el: $(".sidebar") )
			Backbone.on( "show-add", @loadAdd, @)
			Backbone.on( "show-search", @loadSearchFilter, @)
			Backbone.on( "show-workspaces", @loadTagFilter, @)
			Backbone.on( "show-settings", @loadSettings, @)
			Backbone.on( "show-organise", @loadOrganise, @)
			Backbone.on( "show-keyboard-shortcuts", @showKeyboardShortcuts, @)
			Backbone.on( "hide-sidemenu", @hideSideMenu, @)
			Backbone.on("settings/view", @loadSubSettings, @)

		showKeyboardShortcuts: ->
			@keyboard?.destroy()
			@keyboard = new KeyboardOverlay()
			$('.overlay.keyboard').remove()
			$("body").append @keyboard.render().el
			@keyboard.show()
		loadSearchFilter: ->
			if @searchFilter?
				@searchFilter.destroy()
			@searchFilter = new SearchFilter()
			@loadSubmenu @searchFilter, "Search", "icon-materialSearch", 0, "search"
			@searchFilter.$el.find('input').focus()
		loadAdd: ->
			if @addMenu?
				@addMenu.destroy()
			@addMenu = new TaskInputView()
			@loadSubmenu @addMenu, "Add a task", "icon-materialAdd", 0, "addtask"
			@addMenu.$el.find("textarea").focus()
		loadTagFilter: ->
			if @tagFilter?
				@tagFilter.destroy()
			@tagFilter = new TagFilter()
			@loadSubmenu @tagFilter, "Workspaces", "icon-materialWorkspaces", 0, "workspaces"
		loadSettings: ->
			if @settingsMenu?
				@settingsMenu.destroy()
			@settingsMenu = new SidemenuSettings()
			@loadSubmenu( @settingsMenu, "Settings", "icon-materialSettings", 0, "settings" )
		loadOrganise: ->
			@organisebar?.destroy()
			@organisebar = new OrganiseBar()
			@loadSubmenu( @organisebar , null, null, 0, "organise" )
		hideSideMenu: ->
			if @currentMenu?
				@removeSubmenu()
		loadSubSettings: (view) ->
			if view is "snoozes"
				menu = new SidemenuSnoozes()
				title = "Snoozes"
				iconString = "icon-materialSchedule"
				level = 1
			if view is "tweaks"
				menu = new SidemenuTweaks()
				title = "Tweaks"
				iconString = "icon-materialSettings"
				level = 1
			if view is "integrations"
				menu = new SidemenuIntegrations()
				title = "Integrations"
				iconString = "icon-materialSettings"
				level = 1
			if menu?
				@loadSubmenu(menu, title, iconString, level)
		loadSubmenu: (menu, title, iconString, level, activeEl) ->
			if @currentMenu?
				@currentMenu.destroy()
			@currentMenu = menu
			swipy.shortcuts.setDelegate(menu)
			
			@level = level

			# Remove and set selected icon
			if activeEl? and activeEl
				$('.sidebar a.btn-icon').removeClass("active")
				$('.sidebar a.btn-icon.'+activeEl).addClass("active")
				$('.sidebar .sidebar-controls').addClass( "hasActiveEl")

			# Tell application that sidebar is open and load contents
			if menu and menu.el and title
				el = menu.el
				$('.sidebar .sidebar-sub .sub-title > span').html title # title
				$("body").addClass("sidebar-open")
				$(".sidebar").addClass("sub-open")
				$(".sidebar .sidebar-sub .sub-content").html el # content
			if iconString
				$('.sidebar .sidebar-sub .sub-title > svg > use').attr("xlink:href","#"+iconString)
			
		removeSubmenu: ->
			if @currentMenu?
				@currentMenu.destroy()
				@currentMenu = null
			$('.sidebar a.btn-icon').removeClass("active")
			$('.sidebar .sidebar-controls').removeClass( "hasActiveEl")
			$("body").removeClass("sidebar-open")
			$(".sidebar").removeClass("sub-open")
		popView: (force) ->
			if @level is 0 or force
				@removeSubmenu()
				swipy.router.openLastMainView(true)
			else 
				currentPath = Backbone.history.fragment
				lastSeperator = currentPath.lastIndexOf("/");
				newPath = currentPath.substring 0, lastSeperator
				swipy.router.navigate(newPath, true)
		destroy: ->
			Backbone.off( null, null, @ )
			@view.destroy()
			@currentMenu?.destroy()