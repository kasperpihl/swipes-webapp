(function() {
  define(['controller/ViewController', 'router/MainRouter', 'collection/ToDoCollection'], function(ViewController, MainRouter, ToDoCollection) {
    var Swipes;
    return Swipes = (function() {
      function Swipes() {
        this.todos = new ToDoCollection();
        this.todos.on("reset", this.init, this);
        this.fetchTodos();
      }

      Swipes.prototype.init = function() {
        this.viewController = new ViewController();
        this.router = new MainRouter();
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
