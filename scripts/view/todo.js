(function() {
  define(['view/default-view'], function(DefaultView) {
    var MapView;
    MapView = DefaultView.extend({
      init: function() {
        return log("ToDo view initialized");
      },
      cacheEls: function() {}
    });
    return MapView;
  });

}).call(this);
