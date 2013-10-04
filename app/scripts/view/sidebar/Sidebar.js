(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      events: {
        "click .close-sidebar": "handleAction",
        "click .settings": "handleAction",
        "click .log-out": "handleAction"
      },
      initialize: function() {
        _.bindAll(this, "handleAction");
        return $(".open-sidebar").on("click", this.handleAction);
      },
      handleAction: function(e) {
        var trigger;
        trigger = $(e.currentTarget);
        if (trigger.hasClass("open-sidebar")) {
          return $("body").toggleClass("sidebar-open", true);
        } else if (trigger.hasClass("close-sidebar")) {
          return $("body").toggleClass("sidebar-open", false);
        } else if (trigger.hasClass("log-out")) {
          e.preventDefault();
          return console.log("Log out");
        } else if (trigger.hasClass("settings")) {
          return console.log("Go to settings");
        }
      }
    });
  });

}).call(this);
