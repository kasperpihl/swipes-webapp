(function() {
  define(["underscore", "view/List", "controller/ListSortController", "model/TaskSortModel"], function(_, ListView, ListSortController, TaskSortModel) {
    return ListView.extend({
      initialize: function() {
        this.sorter = new TaskSortModel();
        return ListView.prototype.initialize.apply(this, arguments);
      },
      sortTasks: function(tasks) {
        return _.sortBy(tasks, function(model) {
          return model.get("order");
        });
      },
      groupTasks: function(tasksArr) {
        tasksArr = this.sortTasks(tasksArr);
        return [
          {
            deadline: "Tasks",
            tasks: tasksArr
          }
        ];
      },
      setTodoOrder: function(todos) {
        return this.sorter.setTodoOrder(todos);
      },
      beforeRenderList: function(todos) {
        return this.setTodoOrder(todos);
      },
      afterRenderList: function(todos) {
        var _this = this;
        if (!todos.length) {
          return;
        }
        if (this.sortController != null) {
          this.sortController.destroy();
        }
        if (this.transitionDeferred != null) {
          return this.transitionDeferred.done(function() {
            _this.disableNativeClickHandlers();
            return _this.sortController = new ListSortController(_this.$el, _this.subviews);
          });
        }
      },
      disableNativeClickHandlers: function() {
        var view, _i, _len, _ref, _results;
        _ref = this.subviews;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          _results.push(view.$el.off("click", ".todo-content"));
        }
        return _results;
      },
      customCleanUp: function() {
        console.log("Cleaning up view");
        if (this.sortController != null) {
          this.sortController.destroy();
        }
        return this.sortController = null;
      }
    });
  });

}).call(this);
