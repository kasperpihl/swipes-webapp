(function() {
  define(["view/List"], function(ListView) {
    return ListView.extend({
      getListItems: function() {
        console.log("Completed: ", swipy.todos.getCompleted());
        return swipy.todos.getCompleted();
      }
    });
  });

}).call(this);
