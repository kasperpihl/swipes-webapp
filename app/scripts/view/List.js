(function() {
  define(["underscore", "view/Default", "text!templates/todo-list.html"], function(_, DefaultView, ToDoListTmpl) {
    return DefaultView.extend({
      events: Modernizr.touch ? "tap" : "click ",
      init: function() {
        this.template = _.template(ToDoListTmpl);
        this.subviews = [];
        return swipy.todos.on("add remove reset", this.renderList, this);
      },
      render: function() {
        this.renderList();
        return this;
      },
      groupTasks: function(tasksArr) {
        var deadline, tasks, tasksByDate;
        tasksByDate = _.groupBy(tasksArr, function(m) {
          return m.get("scheduleString");
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
      getListItems: function() {
        return swipy.todos.getActive();
      },
      renderList: function() {
        var type,
          _this = this;
        type = Modernizr.touch ? "Touch" : "Desktop";
        return require(["view/list/" + type + "ListItem"], function(ListItemView) {
          var $html, group, list, model, tasksJSON, todos, _i, _j, _len, _len1, _ref, _ref1;
          _this.$el.empty();
          todos = _this.getListItems();
          _ref = _this.groupTasks(todos);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            group = _ref[_i];
            tasksJSON = _.invoke(group.tasks, "toJSON");
            $html = $(_this.template({
              title: group.deadline,
              tasks: tasksJSON 
            }));
            list = $html.find("ol");
            _ref1 = group.tasks;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              model = _ref1[_j];
              list.append(new ListItemView({
                model: model
              }).el);
            }
            _this.$el.append($html);
          }
          return _this.afterRenderList(todos);
        });
      },
      afterRenderList: function(collection) {},
      customCleanUp: function() {
        var view, _i, _len, _ref, _results;
        swipy.todos.off();
        _ref = this.subviews;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          _results.push(view.remove());
        }
        return _results;
      }
    });
  });

}).call(this);
