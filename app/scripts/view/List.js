(function() {
  define(["view/Default", "text!templates/todo-list.html"], function(DefaultView, TodoListTemplate) {
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
      getDummyData: function() {
        return [
          {
            title: "Follow up on Martin",
            order: 0,
            schedule: new Date(),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["work", "client"],
            notes: ""
          }, {
            title: "Make visual research",
            order: 1,
            schedule: new Date(),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["work", "Project y19"],
            notes: ""
          }, {
            title: "Buy a new Helmet",
            order: 2,
            schedule: new Date(),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Personal", "Bike", "Outside"],
            notes: ""
          }, {
            title: "Renew Wired Magazine subscription",
            order: 3,
            schedule: new Date(),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Personal", "Home"],
            notes: ""
          }, {
            title: "Get a Haircut",
            order: 4,
            schedule: new Date(),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Errand", "Home"],
            notes: ""
          }, {
            title: "Clean up the house",
            order: 5,
            schedule: new Date(),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["Errand", "City"],
            notes: ""
          }
        ];
      },
      renderList: function() {
        var items;
        items = new Backbone.Collection(this.getDummyData());
        this.$el.html(this.template({
          items: items.toJSON()
        }));
        return this.afterRenderList(items);
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
