(function() {
  define(['view/List'], function(ListView) {
    return ListView.extend({
      getListItems: function() {
        return swipy.todos.getScheduled();
      }
    });
  });

}).call(this);
