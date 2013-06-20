(function() {
  define(['controller/PageController', 'router/MainRouter'], function(PageController, MainRouter) {
    var Bootstrap;
    return Bootstrap = (function() {
      function Bootstrap() {
        this.init();
      }

      Bootstrap.prototype.init = function() {
        this.pageController = new PageController();
        this.router = new MainRouter();
        return Backbone.history.start({
          pushState: false
        });
      };

      return Bootstrap;

    })();
  });

}).call(this);
