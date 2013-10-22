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
        return console.log("Router initialized ...");
      },
      root: function() {},
      gotoList: function(id) {
        Backbone.trigger("hide-settings");
        return Backbone.trigger("navigate/view", id);
      },
      edit: function(taskId) {
        Backbone.trigger("hide-settings");
        return Backbone.trigger("edit/task", taskId);
      },
      settings: function(route) {
        console.log("Going to settings");
        Backbone.trigger("show-settings");
        if (route) {
          return Backbone.trigger("settings/view", route);
        }
      }
    });
  });

}).call(this);
