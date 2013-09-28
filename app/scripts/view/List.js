(function() {
  define(["underscore", "view/Default", "view/list/ActionBar", "text!templates/todo-list.html"], function(_, DefaultView, ActionBar, ToDoListTmpl) {
    return DefaultView.extend({
      init: function() {
        this.transitionDeferred = new $.Deferred();
        this.template = _.template(ToDoListTmpl);
        this.subviews = [];
        this.renderList = _.debounce(this.renderList, 300);
        this.listenTo(swipy.todos, "add remove reset change:completionDate change:schdule", this.renderList);
        return this.listenTo(Backbone, "complete-task", this.completeTasks);
      },
      render: function() {
        this.renderList();
        return this;
      },
      sortTasks: function(tasks) {
        return _.sortBy(tasks, function(model) {
          return model.get("schedule").getTime();
        });
      },
      groupTasks: function(tasksArr) {
        var deadline, tasks, tasksByDate;
        tasksArr = this.sortTasks(tasksArr);
        tasksByDate = _.groupBy(tasksArr, function(m) {
          return m.get("scheduleStr");
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
        return swipy.todos.getActive();
      },
      renderList: function() {
        var type,
          _this = this;
        console.log("Render list");
        type = Modernizr.touch ? "Touch" : "Desktop";
        return require(["view/list/" + type + "Task"], function(TaskView) {
          var $html, group, list, model, tasksJSON, todos, view, _i, _j, _len, _len1, _ref, _ref1;
          _this.$el.empty();
          _this.killSubViews();
          todos = _this.getTasks();
          _this.beforeRenderList(todos);
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
              view = new TaskView({
                model: model
              });
              _this.subviews.push(view);
              list.append(view.el);
            }
            _this.$el.append($html);
          }
          return _this.afterRenderList(todos);
        });
      },
      beforeRenderList: function(todos) {},
      afterRenderList: function(todos) {},
      getViewForModel: function(model) {
        var view, _i, _len, _ref;
        _ref = this.subviews;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          if (view.model.cid === model.cid) {
            return view;
          }
        }
      },
      completeTasks: function(tasks) {
        var task, view, _i, _len, _results,
          _this = this;
        _results = [];
        for (_i = 0, _len = tasks.length; _i < _len; _i++) {
          task = tasks[_i];
          view = this.getViewForModel(task);
          if (view != null) {
            _results.push(view.doCompleteAnimation().then(function() {
              return task.set("completionDate", new Date());
            }));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      },
      transitionInComplete: function() {
        this.actionbar = new ActionBar();
        return this.transitionDeferred.resolve();
      },
      killSubViews: function() {
        var view, _i, _len, _ref;
        _ref = this.subviews;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          view = _ref[_i];
          view.remove();
        }
        return this.subviews = [];
      },
      customCleanUp: function() {},
      cleanUp: function() {
        this.customCleanUp();
        this.transitionDeferred = null;
        this.stopListening();
        this.actionbar.kill();
        swipy.todos.invoke("set", {
          selected: false
        });
        this.killSubViews();
        return this.$el.empty();
      }
    });
  });

}).call(this);
