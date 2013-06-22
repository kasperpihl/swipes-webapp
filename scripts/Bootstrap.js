(function() {
  define(['controller/ViewController', 'router/MainRouter', 'collection/ToDoCollection'], function(ViewController, MainRouter, ToDoCollection) {
    var Bootstrap;
    return Bootstrap = (function() {
      function Bootstrap() {
        this.init();
      }

      Bootstrap.prototype.init = function() {
        this.viewController = new ViewController();
        this.router = new MainRouter();
        this.collection = new ToDoCollection();
        Backbone.history.start({
          pushState: false
        });
        return this.update();
      };

      Bootstrap.prototype.update = function() {
        return this.collection.fetch();
      };

      return Bootstrap;

    })();
  });

}).call(this);
