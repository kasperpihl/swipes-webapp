define ["js/view/sidebar/Sidebar", "js/view/sidebar/TagFilter", "js/view/sidebar/SearchFilter"], (SidebarView, TagFilter, SearchFilter) ->
	class SidebarController
		constructor: ->
			@view = new SidebarView( el: $(".sidebar") )
		loadSearchFilter: ->
			if @searchFilter?
				@searchFilter.destroy()
			@searchFilter = new SearchFilter()
			@loadSubmenu @searchFilter.el
		loadTagFilter: ->
			if @tagFilter?
				@tagFilter.destroy()
			@tagFilter = new TagFilter()
			@tagFilter.render()
			@loadSubmenu @tagFilter.el
		loadSettings: ->
			if @settingsMenu?
				@settingsMenu.destroy()
		loadSubmenu: (el, level) ->
			$("body").addClass("sidebar-open")
			$(".sidebar").addClass("sub-open")
			$(".sidebar .sidebar-sub .sub-content").html el
		removeSubmenu: ->
			$("body").removeClass("sidebar-open")
			$(".sidebar").removeClass("sub-open")
		destroy: ->
			@view.destroy()
			#@tagFilter.destroy()
			#@searchFilter.destroy()