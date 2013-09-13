(function() {
  define(["view/list/BaseListItem"], function(BaseListItemView) {
    return BaseListItemView.extend({
      events: {
        "click": "toggleSelected"
      },
      toggleSelected: function() {
        var currentlySelected;
        currentlySelected = this.model.get("selected") || false;
        return this.model.set("selected", !currentlySelected);
      }
    });
  });

}).call(this);
