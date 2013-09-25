(function() {
  define(['backbone'], function(Backbone) {
    var MainRouter;
    return MainRouter = Backbone.Router.extend({
      routes: {
        "": "goto",
        ":term": "goto",
        "edit/:id": "edit"
      },
      initialize: function() {
        return console.log("Something is wrong in the state of Denmark...");
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
  });

}).call(this);
