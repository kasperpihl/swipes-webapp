(function() {
  define(['controller/ViewController', 'router/MainRouter', 'collection/ToDoCollection'], function(ViewController, MainRouter, ToDoCollection) {
    var Swipes;
    return Swipes = (function() {
      function Swipes() {
        this.init();
      }

      Swipes.prototype.init = function() {
        this.viewController = new ViewController();
        this.router = new MainRouter();
        this.todos = new ToDoCollection();
        Backbone.history.start({
          pushState: false
        });
        this.update();
        return $(".add-new input").focus();
      };

      Swipes.prototype.update = function() {
        return this.todos.fetch();
      };

      return Swipes;

    })();
  });

}).call(this);
