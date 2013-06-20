(function() {
  define(['controller/ViewController', 'router/MainRouter'], function(ViewController, MainRouter) {
    var Bootstrap;
    return Bootstrap = (function() {
      function Bootstrap() {
        this.init();
      }

      Bootstrap.prototype.init = function() {
        this.viewController = new ViewController();
        this.router = new MainRouter();
        return Backbone.history.start({
          pushState: false
        });
      };

      return Bootstrap;

    })();
  });

}).call(this);
