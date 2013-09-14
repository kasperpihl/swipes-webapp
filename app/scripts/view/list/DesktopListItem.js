(function() {
  define(["view/list/BaseListItem"], function(BaseListItemView) {
    return BaseListItemView.extend({
      events: {
        "click": "toggleSelected"
      },
      toggleSelected: function() {
        var currentlySelected;
        currentlySelected = this.model.get("selected") || false;
        console.log("DesktopListItem change selected to ", !currentlySelected);
        return this.model.set("selected", !currentlySelected);
      }
    });
  });

}).call(this);
