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
        var result;
        result = _.sortBy(todos, function(m) {
          return m.get("schedule").getTime();
        });
        result.reverse();
        return result;
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
      swapSpots: function(newSpot, oldSpot, list) {
        var oldIndex;
        oldIndex = _.indexOf(list, oldSpot);
        return list.splice(oldIndex, 1, newSpot);
      },
      subtractOnce: function(list, val) {
        var diff, result;
        result = _.without(list, val);
        diff = list.length - result.length - 1;
        if (diff > 0) {
          while (diff--) {
            result.push(val);
          }
        }
        return result;
      },
      setTodoOrder: function(todos) {
        var i, order, orders, ordersBefore, ordersMinusCurrent, spot, task, withoutOrder, _i, _j, _k, _len, _len1, _len2;
        orders = _.invoke(todos, "get", "order");
        orders = _.without(orders, void 0);
        ordersBefore = orders;
        withoutOrder = this.sortBySchedule(_.filter(todos, function(m) {
          return !m.has("order");
        }));
        for (i = _i = 0, _len = todos.length; _i < _len; i = ++_i) {
          task = todos[i];
          order = task.get("order");
          if (!_.contains(orders, i)) {
            if (withoutOrder.length) {
              task = withoutOrder.pop();
              task.set("order", i);
              console.log("Found an empty spot. We have a task without order that we can fit in: ", task.get("title"));
              continue;
            } else {
              console.log("Found an empty spot. Swapping current task from " + order + " to " + i);
              this.swapSpots(i, order, orders);
              task.set("order", i);
            }
          }
        }
        for (_j = 0, _len1 = todos.length; _j < _len1; _j++) {
          task = todos[_j];
          order = task.get("order");
          if (order == null) {
            continue;
          }
          if (order >= todos.length) {
            this.swapSpots(todos.length - 1, order, orders);
            order = todos.length - 1;
          }
          ordersMinusCurrent = this.subtractOnce(orders, order);
          if (_.contains(ordersMinusCurrent, order)) {
            spot = this.findSpotForTask(order, ordersMinusCurrent);
            console.log("Spot " + order + " was occupied. swapped for " + spot);
            this.swapSpots(spot, order, orders);
            task.set("order", spot);
          } else if (order === todos.length - 1) {
            console.log("Spot set to last in line (" + order + ")");
            task.set("order", order);
          } else {
            continue;
          }
        }
        if (withoutOrder.length) {
          for (i = _k = 0, _len2 = withoutOrder.length; _k < _len2; i = ++_k) {
            task = withoutOrder[i];
            spot = this.findSpotForTask(i, orders);
            orders.push(spot);
            console.log("A task (" + (task.get('title')) + ") didn't have a spot, so we assigned it " + spot);
            task.set("order", spot);
          }
        }
        console.groupEnd();
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
