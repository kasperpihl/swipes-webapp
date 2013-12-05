(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Parse.View.extend({
      events: {
        "click .close-sidebar": "handleAction",
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
          if (confirm("Are you sure you want to log out?")) {
            Parse.User.logOut();
            return location.pathname = "/login/";
          }
        }
      },
      destroy: function() {
        this.stopListening();
        return $(".open-sidebar").off("click", this.handleAction);
      }
    });
  });

}).call(this);
