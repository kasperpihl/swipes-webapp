(function() {
  define(["underscore", "js/view/List", "js/controller/ListSortController", "js/model/TaskSortModel"], function(_, ListView, ListSortController, TaskSortModel) {
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
        return this.sorter.setTodoOrder(todos, true);
      },
      beforeRenderList: function(todos) {
        swipy.todos.invoke("set", "selected", false);
        return this.setTodoOrder(todos);
      },
      afterRenderList: function(todos) {
        var _this = this;
        if (!todos.length) {
          return;
        }
        if (this.transitionDeferred != null) {
          return this.transitionDeferred.done(function() {
            if (_this.sortController != null) {
              return _this.sortController.model.setViews(_this.subviews);
            } else {
              return _this.sortController = new ListSortController(_this.$el, _this.subviews, function() {
                return _this.render();
              });
            }
          });
        }
      },
      customCleanUp: function() {
        if (this.sortController != null) {
          this.sortController.destroy();
        }
        return this.sortController = null;
      }
    });
  });

}).call(this);
