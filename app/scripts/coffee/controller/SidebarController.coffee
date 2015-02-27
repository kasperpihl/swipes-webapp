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
			@loadSubmenu @searchFilter, "Search", "icon-materialSearch", "search"
			@searchFilter.$el.find('input').focus()
		loadAdd: ->
			if @addMenu?
				@addMenu.destroy()
			@addMenu = new TaskInputView()
			@loadSubmenu @addMenu, "Add a task", "icon-materialAdd", "addtask"
			@addMenu.$el.find("input").focus()
		loadTagFilter: ->
			if @tagFilter?
				@tagFilter.destroy()
			@tagFilter = new TagFilter()
			@loadSubmenu @tagFilter, "Workspaces", "icon-materialWorkspaces", "workspaces"
		loadSettings: ->
			if @settingsMenu?
				@settingsMenu.destroy()
			@settingsMenu = new SidemenuSettings()
			@loadSubmenu( @settingsMenu, "Settings", "icon-materialSettings", "settings" )
		hideSideMenu: ->
			if @currentMenu?
				@removeSubmenu()
		loadSubSettings: (view) ->
			console.log view
			if view is "snoozes"
				menu = new SidemenuSnoozes()
				title = "Snoozes"
				iconString = "icon-materialSchedule"
			if view is "tweaks"
				menu = new SidemenuTweaks()
				title = "Tweaks"
				iconString = "icon-materialSettings"
			if menu?
				@loadSubmenu(menu, title, iconString)
		loadSubmenu: (menu, title, iconString, activeEl) ->
			if @currentMenu?
				@currentMenu.destroy()
			@currentMenu = menu
			el = menu.el

			# Remove and set selected icon
			if activeEl? and activeEl
				$('.sidebar a.btn-icon').removeClass("active")
				$('.sidebar a.btn-icon.'+activeEl).addClass("active")


			
			# Tell application that sidebar is open
			$("body").addClass("sidebar-open")
			$('.sidebar .sidebar-controls').addClass( "hasActiveEl")

			$(".sidebar").addClass("sub-open")

			# Load the actual content
			$('.sidebar .sidebar-sub .sub-title > span').html title # title
			$('.sidebar .sidebar-sub .sub-title > svg > use').attr("xlink:href","#"+iconString)
			$(".sidebar .sidebar-sub .sub-content").html el # content
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
			@currentMenu?.destroy()