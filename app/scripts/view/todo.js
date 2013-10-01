(function() {
  define(["underscore", "view/List", "controller/ListSortController"], function(_, ListView, ListSortController) {
    return ListView.extend({
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
      sortBySchedule: function(todos) {
        return _.sortBy(todos, function(m) {
          return m.get("schedule").getTime();
        });
      },
      getEmptySpotBefore: function(order, orders) {
        var num, _i;
        if (order === 0) {
          return void 0;
        }
        for (num = _i = 0; 0 <= order ? _i <= order : _i >= order; num = 0 <= order ? ++_i : --_i) {
          if (!_.contains(orders, num)) {
            return num;
          }
        }
        return void 0;
      },
      getEmptySpotAfter: function(order, orders) {
        while (_.contains(orders, order)) {
          order++;
        }
        return order;
      },
      findSpotForTask: function(order, orders) {
        var emptySpotBefore;
        emptySpotBefore = this.getEmptySpotBefore(order, orders);
        if (emptySpotBefore != null) {
          return emptySpotBefore;
        }
        return this.getEmptySpotAfter(order, orders);
      },
      setTodoOrder: function(todos) {
        var diff, i, oldSpotIndex, order, orders, ordersMinusCurrent, spot, task, withoutOrder, _i, _j, _len, _len1;
        orders = _.invoke(todos, "get", "order");
        orders = _.without(orders, void 0);
        withoutOrder = [];
        for (_i = 0, _len = todos.length; _i < _len; _i++) {
          task = todos[_i];
          order = task.get("order");
          if (order == null) {
            withoutOrder.push(task);
            continue;
          }
          if (order >= todos.length) {
            order = todos.length - 1;
          }
          ordersMinusCurrent = _.without(orders, order);
          diff = orders.length - ordersMinusCurrent.length - 1;
          if (diff > 0) {
            while (diff--) {
              ordersMinusCurrent.push(order);
            }
          }
          if (_.contains(ordersMinusCurrent, order)) {
            spot = this.findSpotForTask(order, ordersMinusCurrent);
            oldSpotIndex = _.indexOf(orders, order);
            orders.splice(oldSpotIndex, 1, spot);
            task.set("order", spot);
          } else if (order === todos.length - 1) {
            oldSpotIndex = _.indexOf(orders, order);
            orders.splice(oldSpotIndex, 1, spot);
            task.set("order", order);
          } else {
            continue;
          }
        }
        if (withoutOrder.length) {
          withoutOrder = this.sortBySchedule(withoutOrder);
          for (i = _j = 0, _len1 = withoutOrder.length; _j < _len1; i = ++_j) {
            task = withoutOrder[i];
            spot = this.findSpotForTask(i, orders);
            orders.push(spot);
            task.set("order", spot);
          }
        }
        return todos;
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
        return this.transitionDeferred.done(function() {
          _this.disableNativeClickHandlers();
          return _this.sortController = new ListSortController(_this.$el, _this.subviews);
        });
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
        if (this.sortController != null) {
          this.sortController.destroy();
        }
        return this.sortController = null;
      }
    });
  });

}).call(this);
