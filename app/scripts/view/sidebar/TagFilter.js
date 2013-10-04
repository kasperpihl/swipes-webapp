(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      events: {
        "click li": "toggleFilter"
      },
      initialize: function() {
        return console.log("New Tag Filter view created");
      },
      toggleFilter: function(e) {
        var el, tag;
        tag = e.currentTarget.innerText;
        el = $(e.currentTarget).toggleClass("selected");
        if (el.hasClass("selected")) {
          return console.log("Filter for ", tag);
        } else {
          return console.log("De-filter for ", tag);
        }
      }
    });
  });

}).call(this);
