(function() {
  define(["js/view/List"], function(ListView) {
    return ListView.extend({
      getTasks: function() {
        return swipy.todos.getScheduled();
      }
    });
  });

}).call(this);
