define ["js/view/sidebar/Sidebar", "js/view/sidebar/TagFilter", "js/view/sidebar/SearchFilter", "js/view/sidebar/TaskInput", "js/view/sidebar/SidemenuSettings"], (SidebarView, TagFilter, SearchFilter, TaskInputView, SidemenuSettings) ->
	class SidebarController
		constructor: ->
			@view = new SidebarView( el: $(".sidebar") )
		loadSearchFilter: ->
			if @searchFilter?
				@searchFilter.destroy()
			@searchFilter = new SearchFilter()
			@loadSubmenu @searchFilter
		loadAdd: ->
			if @addMenu?
				@addMenu.destroy()
			@addMenu = new TaskInputView()
			@loadSubmenu @addMenu
		loadTagFilter: ->
			if @tagFilter?
				@tagFilter.destroy()
			@tagFilter = new TagFilter()
			@loadSubmenu @tagFilter
		loadSettings: ->
			if @settingsMenu?
				@settingsMenu.destroy()
			@settingsMenu = new SidemenuSettings()
			@loadSubmenu( @settingsMenu )
		loadSubmenu: (menu, level) ->
			if @currentMenu?
				@currentMenu.destroy()
			@currentMenu = menu
			el = menu.el
			$("body").addClass("sidebar-open")
			$(".sidebar").addClass("sub-open")
			$(".sidebar .sidebar-sub .sub-content").html el
		removeSubmenu: ->
			if @currentMenu?
				@currentMenu.destroy()
			$("body").removeClass("sidebar-open")
			$(".sidebar").removeClass("sub-open")
		destroy: ->
			@view.destroy()
			@tagFilter?.destroy()
			@searchFilter?.destroy()
			@addMenu?.destroy()