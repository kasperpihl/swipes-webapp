define ["js/view/sidebar/Sidebar", "js/view/sidebar/TagFilter", "js/view/sidebar/SearchFilter"], (SidebarView, TagFilter, SearchFilter) ->
	class SidebarController
		constructor: ->
			@view = new SidebarView( el: $(".sidebar") )
		loadSearchFilter: ->
			if @searchFilter?
				@searchFilter.destroy()
			@searchFilter = new SearchFilter()
			@searchFilter.render()
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
			$(".sidebar .sidebar-sub").addClass("sub-open").css({"display":"block","backgroundColor":"black"})
			$(".sidebar .sidebar-sub").html el
		destroy: ->
			@view.destroy()
			#@tagFilter.destroy()
			#@searchFilter.destroy()