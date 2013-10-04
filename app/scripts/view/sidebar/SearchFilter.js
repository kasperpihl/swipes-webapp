(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      initialize: function() {
        return console.log("New Search Filter view created");
      }
    });
  });

}).call(this);
