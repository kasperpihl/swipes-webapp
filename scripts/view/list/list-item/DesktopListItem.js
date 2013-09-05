(function() {
  define(["view/list/BaseListItem"], function(BaseListItemView) {
    return BaseListItemView.extend({
      enableInteraction: function() {
        return console.log("Enabling interaction for desktop");
      },
      disableInteraction: function() {
        return console.warn("Disabling interaction for desktop for ", this.model.toJSON());
      }
    });
  });

}).call(this);
