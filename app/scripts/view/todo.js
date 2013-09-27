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
        var i, m, pushOrderCount, takenPositions, view, _i, _len, _ref;
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
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          view = _ref[i];
          if (!(!view.model.has("order"))) {
            continue;
          }
          while (_.contains(takenPositions, i + pushOrderCount)) {
            pushOrderCount++;
          }
          view.model.set("order", i + pushOrderCount);
        }
        return this.renderList();
      },
      afterRenderList: function(todos) {
        var _this = this;
        if (_.any(todos, function(m) {
          return !m.has("order");
        })) {
          return this.setTodoOrder(todos);
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
          _results.push(view.$el.off("click"));
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
