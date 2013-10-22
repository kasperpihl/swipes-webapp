(function() {
  define(["controller/ViewController", "router/MainRouter", "collection/ToDoCollection", "collection/TagCollection", "view/nav/ListNavigation", "controller/TaskInputController", "controller/SidebarController", "controller/ScheduleController", "controller/FilterController", "controller/SettingsController", "controller/ErrorController"], function(ViewController, MainRouter, ToDoCollection, TagCollection, ListNavigation, TaskInputController, SidebarController, ScheduleController, FilterController, SettingsController, ErrorController) {
    var Swipes;
    return Swipes = (function() {
      function Swipes() {
        this.errors = new ErrorController();
        this.todos = new ToDoCollection();
        this.todos.on("reset", this.init, this);
        this.fetchTodos();
      }

      Swipes.prototype.init = function() {
        this.router = new MainRouter();
        if (Backbone.History.started) {
          Backbone.history.stop();
        }
        return Backbone.history.start({
          pushState: false
        });
      };

      Swipes.prototype.fetchTodos = function() {
        return this.todos.fetch();
      };

      return Swipes;

    })();
  });

}).call(this);
