(function() {
  define(['view/default-view'], function(DefaultView) {
    return DefaultView.extend({
      init: function() {
        return log("Schedule view initialized");
      },
      cacheEls: function() {}
    });
  });

}).call(this);
