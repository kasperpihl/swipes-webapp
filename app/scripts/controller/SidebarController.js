(function() {
  define(["view/sidebar/Sidebar", "view/sidebar/TagFilter", "view/sidebar/SearchFilter"], function(SidebarView, TagFilter, SearchFilter) {
    var SidebarController;
    return SidebarController = (function() {
      function SidebarController() {
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

      SidebarController.prototype.destroy = function() {
        this.view.destroy();
        this.tagFilter.destroy();
        return this.searchFilter.destroy();
      };

      return SidebarController;

    })();
  });

}).call(this);
