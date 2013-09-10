(function() {
  define(['controller/ViewController', 'router/MainRouter', 'collection/ToDoCollection'], function(ViewController, MainRouter, ToDoCollection) {
    var Swipes;
    return Swipes = (function() {
      function Swipes() {
        this.init();
      }

      Swipes.prototype.init = function() {
        console.log("initialized app");
        this.viewController = new ViewController();
        this.router = new MainRouter();
        this.collection = new ToDoCollection();
        Backbone.history.start({
          pushState: false
        });
        this.update();
        return $(".add-new input").focus();
      };

      Swipes.prototype.update = function() {
        return this.collection.fetch();
      };

      return Swipes;

    })();
  });

}).call(this);
