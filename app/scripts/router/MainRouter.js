(function() {
  define(['backbone'], function(Backbone) {
    var MainRouter;
    return MainRouter = Backbone.Router.extend({
      routes: {
        "settings(/:id)": "settings",
        "edit/:id": "edit",
        "list/:id": "gotoList",
        "*all": "root"
      },
      initialize: function() {
        this.history = [];
        return this.on("route", this.updateHistory);
      },
      root: function() {
        return this.navigate("list/todo", true);
      },
      gotoList: function(id) {
        console.log("Go to list " + id);
        Backbone.trigger("hide-settings");
        return Backbone.trigger("navigate/view", id);
      },
      edit: function(taskId) {
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
      updateHistory: function() {
        return this.history.push(arguments);
      },
      back: function() {
        if (this.history.length > 1) {
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
