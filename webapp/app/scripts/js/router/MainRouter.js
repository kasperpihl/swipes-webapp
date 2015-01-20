(function() {
  define(['backbone'], function(Backbone) {
    var MainRouter;
    return MainRouter = Backbone.Router.extend({
      routes: {
        "settings/:id": "settings",
        "settings": "settings",
        "edit/:id": "edit",
        "list/:id": "list",
        "*all": "root"
      },
      initialize: function() {
        this.history = [];
        return Backbone.history.on("route", this.updateHistory, this);
      },
      root: function() {
        return this.navigate("list/todo", {
          trigger: true,
          replace: true
        });
      },
      list: function(id) {
        var eventName;
        if (id == null) {
          id = "todo";
        }
        Backbone.trigger("hide-settings");
        Backbone.trigger("navigate/view", id);
        eventName = (function() {
          switch (id) {
            case "todo":
              return "Today Tab";
            case "scheduled":
              return "Later Tab";
            case "completed":
              return "Done Tab";
          }
        })();
        return swipy.analytics.pushScreen(eventName);
      },
      edit: function(taskId) {
        Backbone.trigger("hide-settings");
        return Backbone.trigger("edit/task", taskId);
      },
      settings: function(subview) {
        Backbone.trigger("show-settings");
        if (subview) {
          return Backbone.trigger("settings/view", subview);
        } else {
          return swipy.analytics.pushScreen("Settings menu");
        }
      },
      updateHistory: function(me, page, subpage) {
        var newRoute;
        if (page === "" || page === "root") {
          return false;
        }
        newRoute = this.getRouteStr(page, subpage[0]);
        if (this.getCurrRoute() !== newRoute) {
          return this.history.push(newRoute);
        }
      },
      getRouteStr: function(method, page) {
        if (page) {
          return "" + method + "/" + page;
        } else {
          return method;
        }
      },
      getCurrRoute: function() {
        return this.history[this.history.length - 1];
      },
      back: function() {
        if (this.history.length > 1) {
          this.history.pop();
          return this.navigate(this.history[this.history.length - 1], {
            trigger: true,
            replace: true
          });
        } else {
          return this.root();
        }
      },
      destroy: function() {
        return Backbone.history.off(null, null, this);
      }
    });
  });

}).call(this);
