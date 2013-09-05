(function() {
  define(['backbone'], function(Backbone) {
    var MainRouter;
    MainRouter = Backbone.Router.extend({
      routes: {
        ':term': 'goto',
        '': 'goto'
      },
      goto: function(route) {
        if (route == null) {
          route = 'todo';
        }
        return $(document).trigger('navigate/page', [route]);
      }
    });
    return MainRouter;
  });

}).call(this);
