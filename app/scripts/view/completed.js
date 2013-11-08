(function() {
  define(["view/List"], function(ListView) {
    return ListView.extend({
      sortTasks: function(tasks) {
        var result;
        result = _.sortBy(tasks, function(model) {
          var _base;
          return typeof (_base = model.get("completionDate")).getTime === "function" ? _base.getTime() : void 0;
        });
        return result.reverse();
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
      },
      markTaskAsTodo: function(tasks) {
        var task, view, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = tasks.length; _i < _len; _i++) {
          task = tasks[_i];
          view = this.getViewForModel(task);
          if (view != null) {
            _results.push((function() {
              var m,
                _this = this;
              m = task;
              return view.swipeLeft("todo").then(function() {
                return m.set({
                  completionDate: null,
                  schedule: new Date()
                });
              });
            })());
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    });
  });

}).call(this);
