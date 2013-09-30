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
      setTodoOrder: function(todos) {
        var i, m, pushOrderCount, takenPositions, view, _i, _len, _ref, _results;
        takenPositions = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = todos.length; _i < _len; _i++) {
            m = todos[_i];
            if (m.has("order")) {
              _results.push(m.get("order"));
            }
          }
          return _results;
        })();
        pushOrderCount = 0;
        _ref = this.subviews;
        _results = [];
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          view = _ref[i];
          if (!(!view.model.has("order"))) {
            continue;
          }
          while (_.contains(takenPositions, i + pushOrderCount)) {
            pushOrderCount++;
          }
          _results.push(view.model.set("order", i + pushOrderCount));
        }
        return _results;
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
        return this.transitionDeferred.done(function() {});
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
