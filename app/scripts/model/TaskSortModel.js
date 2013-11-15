(function() {
  define(["underscore"], function(_) {
    var TaskSortModel;
    return TaskSortModel = (function() {
      function TaskSortModel() {}

      TaskSortModel.prototype.sortBySchedule = function(todos) {
        var result;
        result = _.sortBy(todos, function(m) {
          return m.get("schedule").getTime();
        });
        result.reverse();
        return result;
      };

      TaskSortModel.prototype.getEmptySpotBefore = function(order, orders) {
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
      };

      TaskSortModel.prototype.getEmptySpotAfter = function(order, orders) {
        while (_.contains(orders, order)) {
          order++;
        }
        return order;
      };

      TaskSortModel.prototype.findSpotForTask = function(order, orders) {
        var emptySpotBefore;
        emptySpotBefore = this.getEmptySpotBefore(order, orders);
        if (emptySpotBefore != null) {
          return emptySpotBefore;
        } else {
          return this.getEmptySpotAfter(order, orders);
        }
      };

      TaskSortModel.prototype.swapSpots = function(newSpot, oldSpot, list) {
        var oldIndex;
        oldIndex = _.indexOf(list, oldSpot);
        return list.splice(oldIndex, 1, newSpot);
      };

      TaskSortModel.prototype.subtractOnce = function(list, val) {
        var diff, result;
        result = _.without(list, val);
        diff = list.length - result.length - 1;
        if (diff > 0) {
          while (diff--) {
            result.push(val);
          }
        }
        return result;
      };

      TaskSortModel.prototype.setTodoOrder = function(todos) {
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
              continue;
            } else {
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
            this.swapSpots(spot, order, orders);
            task.set("order", spot);
          } else if (order === todos.length - 1) {
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
      };

      return TaskSortModel;

    })();
  });

}).call(this);
