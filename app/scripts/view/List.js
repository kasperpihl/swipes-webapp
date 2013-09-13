(function() {
  define(["underscore", "view/Default", "text!templates/todo-list.html"], function(_, DefaultView, TodoListTemplate) {
    return DefaultView.extend({
      events: Modernizr.touch ? "tap" : "click ",
      init: function() {
        this.template = _.template(TodoListTemplate);
        return this.subviews = [];
      },
      render: function() {
        this.renderList();
        return this;
      },
      groupTasks: function(data) {
        var deadline, tasks, tasksByDate;
        tasksByDate = _.groupBy(data, function(json) {
          return json.scheduleString;
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
            schedule: new Date("September 16, 2013 16:30:02"),
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
            schedule: new Date("March 1, 2014 16:30:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Personal", "Bike", "Outside"],
            notes: ""
          }, {
            title: "Renew Wired Magazine subscription",
            order: 3,
            schedule: new Date("September 14, 2013 16:30:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Personal", "Home"],
            notes: ""
          }, {
            title: "Get a Haircut",
            order: 4,
            schedule: new Date("September 14, 2013 16:30:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Errand", "Home"],
            notes: ""
          }, {
            title: "Clean up the house",
            order: 5,
            schedule: new Date("September 15, 2013 16:30:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Errand", "City"],
            notes: ""
          }
        ];
      },
      renderList: function() {
        var col, items,
          _this = this;
        items = this.getDummyData();
        col = new Backbone.Collection();
        return require(["model/ToDoModel"], function(Model) {
          var obj, _i, _len;
          col.model = Model;
          for (_i = 0, _len = items.length; _i < _len; _i++) {
            obj = items[_i];
            col.add(obj);
          }
          _this.$el.html(_this.template({
            taskGroups: _this.groupTasks(col.toJSON())
          }));
          return _this.afterRenderList(items);
        });
      },
      afterRenderList: function(models) {
        var type,
          _this = this;
        type = Modernizr.touch ? "Touch" : "Desktop";
        return require(["view/list/" + type + "ListItem"], function(ListItemView) {
          return _this.$el.find('ol.todo > li').each(function(i, el) {
            return _this.subviews.push(new ListItemView({
              el: el,
              model: models.at(i)
            }));
          });
        });
      },
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
