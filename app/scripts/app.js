(function() {
  define(["controller/ViewController", "router/MainRouter", "collection/ToDoCollection", "collection/TagCollection", "view/nav/ListNavigation", "controller/ScheduleController"], function(ViewController, MainRouter, ToDoCollection, TagCollection, ListNavigation, ScheduleController) {
    var Swipes;
    return Swipes = (function() {
      function Swipes() {
        this.todos = new ToDoCollection();
        this.todos.on("reset", this.init, this);
        this.fetchTodos();
      }

      Swipes.prototype.init = function() {
        this.tags = new TagCollection();
        this.viewController = new ViewController();
        this.nav = new ListNavigation();
        this.router = new MainRouter();
        this.scheduler = new ScheduleController();
        Backbone.history.start({
          pushState: false
        });
        return $(".add-new input").focus();
      };

      Swipes.prototype.fetchTodos = function() {
        return this.todos.fetch();
      };

      return Swipes;

    })();
  });

}).call(this);
