(function() {
  define(['backbone'], function(Backbone) {
    var MainRouter;
    MainRouter = Backbone.Router.extend({
      routes: {
        ":term": "goto",
        "edit/:id": "edit",
        "": "goto"
      },
      goto: function(route) {
        if (route == null) {
          route = "todo";
        }
        return Backbone.trigger("navigate/view", route);
      },
      edit: function(taskId) {
        return Backbone.trigger("edit/task", taskId);
      }
    });
    return MainRouter;
  });

}).call(this);
