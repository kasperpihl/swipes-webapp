(function() {
  define(["underscore", "view/Default", "text!templates/todo-list.html"], function(_, DefaultView, ToDoListTmpl) {
    return DefaultView.extend({
      events: Modernizr.touch ? "tap" : "click ",
      init: function() {
        this.template = _.template(ToDoListTmpl);
        return this.subviews = [];
      },
      render: function() {
        this.renderList();
        return this;
      },
      groupTasks: function(collection) {
        var deadline, tasks, tasksByDate;
        tasksByDate = collection.groupBy(function(m) {
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
      getDummyData: function() {
        return [
          {
            title: "Follow up on Martin",
            order: 0,
            schedule: new Date("September 19, 2013 16:30:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["work", "client"],
            notes: ""
          }, {
            title: "Make visual research",
            order: 1,
            schedule: new Date("October 13, 2013 11:13:00"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["work", "Project y19"],
            notes: ""
          }, {
            title: "Buy a new Helmet",
            order: 2,
            schedule: new Date("March 1, 2017 16:30:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            notes: ""
          }, {
            title: "Renew Wired Magazine subscription",
            order: 3,
            schedule: new Date("September 17, 2013 20:30:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Personal", "Home"],
            notes: ""
          }, {
            title: "Get a Haircut",
            order: 4,
            schedule: new Date("September 17, 2013 23:59:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            notes: ""
          }, {
            title: "Clean up the house",
            order: 5,
            schedule: new Date("September 16, 2013 22:30:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Errand", "City"],
            notes: ""
          }
        ];
      },
      renderList: function() {
        var col, items, type,
          _this = this;
        items = this.getDummyData();
        col = new Backbone.Collection();
        type = Modernizr.touch ? "Touch" : "Desktop";
        window.app.todos = col;
        this.$el.empty();
        return require(["model/ToDoModel", "view/list/" + type + "ListItem"], function(Model, ListItemView) {
          var $html, group, list, m, obj, tasksJSON, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
          col.model = Model;
          for (_i = 0, _len = items.length; _i < _len; _i++) {
            obj = items[_i];
            col.add(obj);
          }
          _ref = _this.groupTasks(col);
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            group = _ref[_j];
            tasksJSON = _.invoke(group.tasks, "toJSON");
            $html = $(_this.template({
              title: group.deadline,
              tasks: tasksJSON 
            }));
            list = $html.find("ol");
            _ref1 = group.tasks;
            for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
              m = _ref1[_k];
              list.append(new ListItemView({
                model: m
              }).el);
            }
            _this.$el.append($html);
          }
          return _this.afterRenderList(col);
        });
      },
      afterRenderList: function(collection) {},
      customCleanUp: function() {
        var view, _i, _len, _ref, _results;
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
