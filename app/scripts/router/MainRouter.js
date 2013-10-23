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
        return this.on("route", this.updateHistory);
      },
      root: function() {
        return this.navigate("list/todo", {
          trigger: true,
          replaceState: false
        });
      },
      list: function(id) {
        Backbone.trigger("hide-settings");
        return Backbone.trigger("navigate/view", id);
      },
      edit: function(taskId) {
        console.log("Edit task " + taskId);
        Backbone.trigger("hide-settings");
        return Backbone.trigger("edit/task", taskId);
      },
      settings: function(subview) {
        console.log("Going to settings");
        Backbone.trigger("show-settings");
        if (subview) {
          return Backbone.trigger("settings/view", subview);
        }
      },
      updateHistory: function(method, page) {
        if (method !== "root") {
          return this.history.push(this.getRouteStr(method, page[0]));
        }
      },
      getRouteStr: function(method, page) {
        if (page) {
          return "" + method + "/" + page;
        } else {
          return method;
        }
      },
      back: function() {
        if (this.history.length > 0) {
          return window.history.back();
        } else {
          return this.navigate('list/todo', {
            trigger: true,
            replace: true
          });
        }
      }
    });
  });

}).call(this);
