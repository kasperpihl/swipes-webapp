(function() {
  define(["view/List"], function(ListView) {
    return ListView.extend({
      getListItems: function() {
        return swipy.todos.getCompleted();
      }
    });
  });

}).call(this);
