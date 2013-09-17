(function() {
  require(["jquery", "underscore", "backbone"], function($, _, Backbone) {
    var contentHolder, helpers;
    contentHolder = $("#content-holder");
    helpers = {
      getListItemModels: function() {
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
            title: "Dummy task #3",
            order: 2,
            schedule: new Date(),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["work", "client"],
            notes: ""
          }, {
            title: "Dummy task #2",
            order: 1,
            schedule: new Date("October 13, 2013 11:13:00"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            tags: ["work", "client"],
            notes: ""
          }, {
            title: "Dummy task #4",
            order: 3,
            schedule: new Date("September 18, 2013 16:30:02"),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            notes: ""
          }
        ];
      },
      renderTodoList: function() {
        var dfd;
        dfd = new $.Deferred();
        require(["text!templates/todo-list.html", "model/ToDoModel", "view/list/DesktopListItem"], function(ListTempl, Model, View) {
          var data, tmpl;
          tmpl = _.template(ListTempl);
          data = {
            title: "Tomorrow"
          };
          contentHolder.html($("<ol class='todo'></ol>").append(tmpl(data)));
          return dfd.resolve();
        });
        return dfd.promise();
      }
    };
    describe("Basics", function() {
      return it("App should be up and running", function() {
        return expect(swipy).to.exist;
      });
    });
    require(["model/ToDoModel"], function(Model) {
      return describe("List Item model", function() {
        var model;
        model = new Model();
        it("Should create scheduleStr property when instantiated", function() {
          return expect(model.get("scheduleString")).to.equal("the past");
        });
        it("Should update scheduleStr when schedule property is changed", function() {
          var date;
          date = model.get("schedule");
          model.unset("schedule");
          date.setDate(date.getDate() + 1);
          model.set("schedule", date);
          return expect(model.get("scheduleString")).to.equal("Tomorrow");
        });
        it("Should create timeStr property when model is instantiated", function() {
          return expect(model.get("timeStr")).to.exist;
        });
        return it("Should update timeStr when schedule property is changed", function() {
          var date, timeAfterChange, timeBeforeChange;
          timeBeforeChange = model.get("timeStr");
          date = model.get("schedule");
          model.unset("schedule");
          date.setHours(date.getHours() - 1);
          model.set("schedule", date);
          timeAfterChange = model.get("timeStr");
          return expect(timeBeforeChange).to.not.equal(timeAfterChange);
        });
      });
    });
    return require(["collection/ToDoCollection", "model/ToDoModel", "view/list/DesktopListItem"], function(ToDoCollection, Model, View) {
      return helpers.renderTodoList().then(function() {
        var list;
        list = contentHolder.find(".todo ol");
        (function() {
          var model, view;
          model = new Model(helpers.getListItemModels()[0]);
          view = new View({
            model: model
          });
          return describe("To Do View: Selecting", function() {
            list.append(view.el);
            view.$el.click();
            it("Should toggle selected property on model when clicked", function() {
              return expect(model.get("selected")).to.be["true"];
            });
            return it("Should toggle selected class on element when clicked", function() {
              return expect(view.$el.hasClass("selected")).to.be["true"];
            });
          });
        })();
        return (function() {
          var todos, views;
          todos = views = null;
          return describe("To Do View: Hovering", function() {
            beforeEach(function() {
              var model, view, _i, _len, _results;
              list.empty();
              todos = new ToDoCollection(helpers.getListItemModels());
              views = (function() {
                var _i, _len, _ref, _results;
                _ref = todos.models;
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  model = _ref[_i];
                  _results.push(new View({
                    model: model
                  }));
                }
                return _results;
              })();
              _results = [];
              for (_i = 0, _len = views.length; _i < _len; _i++) {
                view = views[_i];
                _results.push(list.append(view.el));
              }
              return _results;
            });
            after(function() {
              return contentHolder.empty();
            });
            it("Should be unresponsive to 'hover-complete' event when not selected", function() {
              var count, view, _i, _len;
              Backbone.trigger("hover-complete");
              count = 0;
              for (_i = 0, _len = views.length; _i < _len; _i++) {
                view = views[_i];
                if (view.$el.hasClass("hover-complete")) {
                  count++;
                }
              }
              return expect(count).to.equal(0);
            });
            it("Should be unresponsive to 'hover-schedule' event when not selected", function() {
              var count, view, _i, _len;
              Backbone.trigger("hover-schedule");
              count = 0;
              for (_i = 0, _len = views.length; _i < _len; _i++) {
                view = views[_i];
                if (view.$el.hasClass("hover-schedule")) {
                  count++;
                }
              }
              return expect(count).to.equal(0);
            });
            it("Should get the 'hover-complete' CSS class when 'hover-complete' event is triggered when selected", function() {
              var count, view, _i, _len;
              views[0].model.set("selected", true);
              views[1].model.set("selected", true);
              Backbone.trigger("hover-complete");
              count = 0;
              for (_i = 0, _len = views.length; _i < _len; _i++) {
                view = views[_i];
                if (view.$el.hasClass("hover-complete")) {
                  count++;
                }
              }
              return expect(count).to.equal(2);
            });
            it("Should remove the 'hover-complete' CSS class when 'unhover-complete' event is triggered when selected", function() {
              var count, view, _i, _len;
              views[0].model.set("selected", true);
              views[1].model.set("selected", true);
              views[0].$el.addClass("hover-complete");
              views[1].$el.addClass("hover-complete");
              Backbone.trigger("unhover-complete");
              count = 0;
              for (_i = 0, _len = views.length; _i < _len; _i++) {
                view = views[_i];
                if (view.$el.hasClass("hover-complete")) {
                  count++;
                }
              }
              return expect(count).to.equal(0);
            });
            it("Should get the 'hover-schedule' CSS class when 'hover-schedule' event is triggered when selected", function() {
              var count, view, _i, _len;
              views[0].model.set("selected", true);
              views[1].model.set("selected", true);
              Backbone.trigger("hover-schedule");
              count = 0;
              for (_i = 0, _len = views.length; _i < _len; _i++) {
                view = views[_i];
                if (view.$el.hasClass("hover-schedule")) {
                  count++;
                }
              }
              return expect(count).to.equal(2);
            });
            return it("Should remove the 'hover-schedule' CSS class when 'unhover-schedule' event is triggered when selected", function() {
              var count, view, _i, _len;
              views[0].model.set("selected", true);
              views[1].model.set("selected", true);
              views[0].$el.addClass("hover-schedule");
              views[1].$el.addClass("hover-schedule");
              Backbone.trigger("unhover-schedule");
              count = 0;
              for (_i = 0, _len = views.length; _i < _len; _i++) {
                view = views[_i];
                if (view.$el.hasClass("hover-schedule")) {
                  count++;
                }
              }
              return expect(count).to.equal(0);
            });
          });
        })();
      });
    });
  });

}).call(this);
