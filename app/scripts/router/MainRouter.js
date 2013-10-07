(function() {
  define(['backbone'], function(Backbone) {
    var MainRouter;
    return MainRouter = Backbone.Router.extend({
      routes: {
        "": "goto",
        ":term": "goto",
        "edit/:id": "edit",
        "settings": "settings",
        "settings/:id": "settings"
      },
      goto: function(route) {
        if (route == null) {
          route = "todo";
        }
        Backbone.trigger("hide-settings");
        return Backbone.trigger("navigate/view", route);
      },
      edit: function(taskId) {
        Backbone.trigger("hide-settings");
        return Backbone.trigger("edit/task", taskId);
      },
      settings: function(route) {
        Backbone.trigger("show-settings");
        return Backbone.trigger("settings/view", route);
      }
    });
  });

}).call(this);
