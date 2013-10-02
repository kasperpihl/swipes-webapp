(function() {
  define(["view/List"], function(ListView) {
    return ListView.extend({
      sortTasks: function(tasks) {
        return _.sortBy(tasks, function(model) {
          var _ref;
          return (_ref = model.get("schedule")) != null ? _ref.getTime() : void 0;
        }).reverse();
      },
      groupTasks: function(tasksArr) {
        var deadline, tasks, tasksByDate;
        tasksArr = this.sortTasks(tasksArr);
        tasksByDate = _.groupBy(tasksArr, function(m) {
          return m.get("completionStr");
        });
        return (function() {
          var _results;
          _results = [];
          for (deadline in tasksByDate) {
            tasks = tasksByDate[deadline];
            _results.push({
              deadline: deadline,
              tasks: tasks
            });
          }
          return _results;
        })();
      },
      getTasks: function() {
        return swipy.todos.getCompleted();
      }
    });
  });

}).call(this);
