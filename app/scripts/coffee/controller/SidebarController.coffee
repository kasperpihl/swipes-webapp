define ["js/view/sidebar/Sidebar", "js/view/sidebar/TagFilter", "js/view/sidebar/SearchFilter", "js/view/sidebar/TaskInput", "js/view/sidebar/SidemenuSettings", "js/view/sidebar/settings/SidemenuSnoozes"], (SidebarView, TagFilter, SearchFilter, TaskInputView, SidemenuSettings, SidemenuSnoozes) ->
	class SidebarController
		constructor: ->
			@view = new SidebarView( el: $(".sidebar") )
			Backbone.on( "show-add", @loadAdd, @)
			Backbone.on( "show-search", @loadSearchFilter, @)
			Backbone.on( "show-workspaces", @loadTagFilter, @)
			Backbone.on( "show-settings", @loadSettings, @)
			Backbone.on( "hide-sidemenu", @hideSideMenu, @)
			Backbone.on("settings/view", @loadSubSettings, @)
		loadSearchFilter: ->
			if @searchFilter?
				@searchFilter.destroy()
			@searchFilter = new SearchFilter()
			@loadSubmenu @searchFilter, "search", "Search"
			@searchFilter.$el.find('input').focus()
		loadAdd: ->
			if @addMenu?
				@addMenu.destroy()
			@addMenu = new TaskInputView()
			@loadSubmenu @addMenu, "addtask", "Add a task"
			@addMenu.$el.find("input").focus()
		loadTagFilter: ->
			if @tagFilter?
				@tagFilter.destroy()
			@tagFilter = new TagFilter()
			@loadSubmenu @tagFilter, "workspaces", "Workspaces"
		loadSettings: ->
			if @settingsMenu?
				@settingsMenu.destroy()
			@settingsMenu = new SidemenuSettings()
			@loadSubmenu( @settingsMenu, "settings", "Settings" )
		hideSideMenu: ->
			if @currentMenu?
				@removeSubmenu()
		loadSubSettings: (view) ->
			console.log view
			if view is "snoozes"
				menu = new SidemenuSnoozes()
			if menu?
				@pushView(menu.el)
		loadSubmenu: (menu, activeEl, title) ->
			if @currentMenu?
				@currentMenu.destroy()
			@currentMenu = menu
			el = menu.el
			$('.sidebar a.btn-icon').removeClass("active")
			$('.sidebar a.btn-icon.'+activeEl).addClass("active")
			$('.sidebar .sidebar-controls').addClass( "hasActiveEl")
			$("body").addClass("sidebar-open")
			$(".sidebar").addClass("sub-open")
			$(".sidebar .sidebar-sub .sub-content").html el
		removeSubmenu: ->
			if @currentMenu?
				@currentMenu.destroy()
				@currentMenu = null
			$('.sidebar a.btn-icon').removeClass("active")
			$('.sidebar .sidebar-controls').removeClass( "hasActiveEl")
			$("body").removeClass("sidebar-open")
			$(".sidebar").removeClass("sub-open")
		pushView: (view) ->
			$(".sidebar .sidebar-sub .sub-content").html view
		popView: ->
			currentPath = Backbone.history.fragment
			lastSeperator = currentPath.lastIndexOf("/");
			newPath = currentPath.substring 0, lastSeperator
			console.log newPath
		destroy: ->
			Backbone.off( null, null, @ )
			@view.destroy()
			@tagFilter?.destroy()
			@searchFilter?.destroy()
			@addMenu?.destroy()
			@settings?.destroy()