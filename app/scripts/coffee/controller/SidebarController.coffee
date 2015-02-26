define ["js/view/sidebar/Sidebar", "js/view/sidebar/TagFilter", "js/view/sidebar/SearchFilter", "js/view/sidebar/TaskInput", "js/view/sidebar/SidemenuSettings"], (SidebarView, TagFilter, SearchFilter, TaskInputView, SidemenuSettings) ->
	class SidebarController
		constructor: ->
			@view = new SidebarView( el: $(".sidebar") )
			Backbone.on( "show-add", @loadAdd, @)
			Backbone.on( "show-search", @loadSearchFilter, @)
			Backbone.on( "show-workspaces", @loadTagFilter, @)
			Backbone.on( "show-settings", @loadSettings, @)
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
				@currentMenu = null
			$("body").removeClass("sidebar-open")
			$(".sidebar").removeClass("sub-open")
		destroy: ->
			Backbone.off( null, null, @ )
			@view.destroy()
			@tagFilter?.destroy()
			@searchFilter?.destroy()
			@addMenu?.destroy()
			@settings?.destroy()