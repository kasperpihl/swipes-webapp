(function() {
  define(["view/List"], function(ListView) {
    return ListView.extend({
      sortTasks: function(tasks) {
        return _.sortBy(tasks, function(model) {
          return model.get("order");
        });
      }
    });
  });

}).call(this);
