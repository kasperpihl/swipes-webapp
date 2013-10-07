(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.Model.extend({
      url: "test",
      defaults: {
        snoozes: [1, 2, 3],
        hasPlus: false
      }
    });
  });

}).call(this);
