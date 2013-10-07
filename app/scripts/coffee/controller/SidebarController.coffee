define ["view/sidebar/Sidebar", "view/sidebar/TagFilter", "view/sidebar/SearchFilter"], (SidebarView, TagFilter, SearchFilter) ->
	class SidebarController
		constructor: ->
			@view = new SidebarView( el: $(".sidebar") )
			@tagFilter = new TagFilter( el: $( ".sidebar .tags-filter" ) )
			@searchFilter = new SearchFilter( el: $( ".sidebar .search" ) )