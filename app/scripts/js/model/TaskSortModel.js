(function() {
  define(["underscore"], function(_) {
    var TaskSortModel;
    return TaskSortModel = (function() {
      function TaskSortModel() {}

      TaskSortModel.prototype.sortBySchedule = function(todos) {
        var result;
        result = _.sortBy(todos, function(m) {
          var schedule;
          schedule = m.get("schedule");
          if (!schedule) {
            return 0;
          } else {
            return schedule.getTime();
          }
        });
        result.reverse();
        return result;
      };

      TaskSortModel.prototype.setTodoOrder = function(todos, newOnTop) {
        var defaultOrderVal, groupedItems, m, orderNumber, orderedItems, sortedTodoArray, unorderedItems, _i, _len;
        defaultOrderVal = -1;
        sortedTodoArray = [];
        groupedItems = _.groupBy(todos, function(m) {
          if (m.has("order") && m.get("order") > defaultOrderVal) {
            return "ordered";
          } else {
            return "unordered";
          }
        });
        if (groupedItems.unordered != null) {
          unorderedItems = this.sortBySchedule(groupedItems.unordered);
          sortedTodoArray = unorderedItems;
        }
        if (groupedItems.ordered != null) {
          orderedItems = _.sortBy(groupedItems.ordered, function(m) {
            return m.get("order");
          });
          sortedTodoArray = newOnTop ? sortedTodoArray.concat(orderedItems) : orderedItems.concat(sortedTodoArray);
        }
        orderNumber = 0;
        for (_i = 0, _len = sortedTodoArray.length; _i < _len; _i++) {
          m = sortedTodoArray[_i];
          if (!m.has("order") || m.get("order") !== orderNumber) {
            m.updateOrder(orderNumber);
          }
          orderNumber++;
        }
        return sortedTodoArray;
      };

      return TaskSortModel;

    })();
  });

}).call(this);
