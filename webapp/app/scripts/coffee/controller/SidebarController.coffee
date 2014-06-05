define ["js/view/sidebar/Sidebar", "js/view/sidebar/TagFilter", "js/view/sidebar/SearchFilter"], (SidebarView, TagFilter, SearchFilter) ->
	class SidebarController
		constructor: ->
			@view = new SidebarView( el: $(".sidebar") )
			@tagFilter = new TagFilter( el: $( ".sidebar .tags-filter" ) )
			@searchFilter = new SearchFilter( el: $( ".sidebar .search" ) )
		destroy: ->
			@view.destroy()
			@tagFilter.destroy()
			@searchFilter.destroy()