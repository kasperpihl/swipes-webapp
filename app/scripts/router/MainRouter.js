(function() {
  define(['backbone'], function(Backbone) {
    var MainRouter;
    return MainRouter = Backbone.Router.extend({
      routes: {
        "settings(/:id)": "settings",
        "edit/:id": "edit",
        "list/:id": "list",
        "*all": "root"
      },
      initialize: function() {
        this.history = [];
        return this.on("route", this.updateHistory, this);
      },
      root: function() {
        return this.navigate("list/todo", {
          trigger: true,
          replace: true
        });
      },
      list: function(id) {
        if (id == null) {
          id = "todo";
        }
        Backbone.trigger("hide-settings");
        return Backbone.trigger("navigate/view", id);
      },
      edit: function(taskId) {
        Backbone.trigger("hide-settings");
        return Backbone.trigger("edit/task", taskId);
      },
      settings: function(subview) {
        Backbone.trigger("show-settings");
        if (subview) {
          return Backbone.trigger("settings/view", subview);
        }
      },
      updateHistory: function(method, page) {
        var newRoute;
        if (method === "root") {
          return false;
        }
        newRoute = this.getRouteStr(method, page[0]);
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
        return this.off("route");
      }
    });
  });

}).call(this);
