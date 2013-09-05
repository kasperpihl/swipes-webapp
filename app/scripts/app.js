(function() {
  define(['controller/ViewController', 'router/MainRouter', 'collection/ToDoCollection'], function(ViewController, MainRouter, ToDoCollection) {
    var Bootstrap;
    return Bootstrap = (function() {
      function Bootstrap() {
        this.init();
      }

      Bootstrap.prototype.init = function() {
        console.log("initialized app");
        /*
        			@viewController = new ViewController()
        			@router = new MainRouter()
        			@collection = new ToDoCollection()
        */

        Backbone.history.start({
          pushState: false
        });
        return $(".add-new input").focus();
      };

      Bootstrap.prototype.update = function() {
        return this.collection.fetch();
      };

      return Bootstrap;

    })();
  });

}).call(this);
