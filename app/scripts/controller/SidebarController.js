(function() {
  define(["view/sidebar/Sidebar", "view/sidebar/TagFilter", "view/sidebar/SearchFilter"], function(SidebarView, TagFilter, SearchFilter) {
    var SidebarController;
    return SidebarController = (function() {
      function SidebarController() {
        console.log("New sidebar controller created");
        this.view = new SidebarView({
          el: $(".sidebar")
        });
        this.tagFilter = new TagFilter({
          el: $(".sidebar .tags-filter")
        });
        this.searchFilter = new SearchFilter({
          el: $(".sidebar .search")
        });
      }

      return SidebarController;

    })();
  });

}).call(this);
