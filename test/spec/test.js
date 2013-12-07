(function() {
  define(["jquery", "underscore", "backbone", "model/ToDoModel", "momentjs"], function($, _, Backbone, ToDoModel, moment) {
    var contentHolder, helpers;
    contentHolder = $("#content-holder");
    helpers = {
      getDummyModels: function() {
        var future;
        future = new Date();
        future.setDate(future.getDate() + 1);
        return [
          {
            title: "Follow up on Martin",
            order: 0,
            schedule: new Date(),
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
            notes: ""
          }, {
            title: "Completed Dummy task #3",
            order: 2,
            schedule: new Date(),
            completionDate: new Date("July 12, 2013 11:51:45"),
            repeatOption: "never",
            repeatDate: null,
            notes: ""
          }, {
            title: "Dummy task #2",
            order: 1,
            schedule: future,
            completionDate: null,
            repeatOption: "never",
            repeatDate: null,
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
        require(["text!templates/task.html", "view/list/DesktopTask"], function(TaskTmpl, View) {
          var model, tmpl;
          tmpl = _.template(TaskTmpl);
          model = new ToDoModel({
            title: "Tomorrow"
          });
          contentHolder.html($("<ol class='todo'></ol>").append(tmpl(model.toJSON())));
          return dfd.resolve();
        });
        return dfd.promise();
      }
    };
    describe("Basics", function() {
      it("App should be up and running", function() {
        swipy.todos.reset(helpers.getDummyModels());
        return expect(swipy).to.exist;
      });
      it("Should have scheduled tasks for testing", function() {
        return expect(swipy.todos.getScheduled()).to.have.length.above(0);
      });
      it("Should have active tasks for testing", function() {
        return expect(swipy.todos.getActive()).to.have.length.above(0);
      });
      return it("Should have completed tasks for testing", function() {
        return expect(swipy.todos.getCompleted()).to.have.length.above(0);
      });
    });
    describe("Task model", function() {
      var model;
      model = new ToDoModel();
      describe("scheduleStr property", function() {
        it("Should create scheduleStr property when instantiated, and the default should be: 'Today'", function() {
          return expect(model.get("scheduleStr")).to.equal("Today");
        });
        it("Should update scheduleStr when schedule property is changed", function() {
          var date;
          date = model.get("schedule");
          model.unset("schedule");
          date.setDate(date.getDate() + 1);
          model.set("schedule", date);
          return expect(model.get("scheduleStr")).to.equal("Tomorrow");
        });
        return describe("differentiate scheduleStr for 'Today' base current time vs. task time", function() {
          it("Should set scheduleStr to be 'Today' if the task is due today, prior to or equal to the current time", function() {
            var earlierToday, taskForEarlierToday;
            earlierToday = new Date();
            earlierToday.setMinutes(earlierToday.getMinutes() - 1);
            taskForEarlierToday = new ToDoModel({
              schedule: earlierToday
            });
            return expect(taskForEarlierToday.get("scheduleStr")).to.equal("Today");
          });
          return it("Should set scheduleStr to be 'Later today' if the task is due today, later than the current time", function() {
            var laterToday, taskForLaterToday;
            laterToday = new Date();
            laterToday.setMinutes(laterToday.getMinutes() + 1);
            taskForLaterToday = new ToDoModel({
              schedule: laterToday
            });
            return expect(taskForLaterToday.get("scheduleStr")).to.equal("Later today");
          });
        });
      });
      describe("timeStr property", function() {
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
      describe("completedStr property", function() {
        return it("Should update completedStr when completionDate is changed", function() {
          model.set("completionDate", new Date());
          expect(model.get("completionStr")).to.exist;
          return expect(model.get("completionTimeStr")).to.exist;
        });
      });
      return describe("tags", function() {
        return it("Should make sure the models tags all exist in the global tags collection — And add them if they don't", function() {
          var dummyTagName;
          dummyTagName = "wtf123-" + new Date().getTime();
          expect(swipy.tags.pluck("title")).to.not.contain(dummyTagName);
          Backbone.trigger("create-task", "Test that we add tags properly #" + dummyTagName);
          return expect(swipy.tags.pluck("title")).to.contain(dummyTagName);
        });
      });
    });
    require(["collection/ToDoCollection"], function(ToDoCollection) {
      return describe("To Do collection", function() {
        var todos;
        todos = null;
        beforeEach(function() {
          var completedTask, future, now, past, scheduledTask, todoTask;
          now = new Date();
          future = new Date();
          past = new Date();
          now.setSeconds(now.getSeconds() - 1);
          future.setDate(now.getDate() + 1);
          past.setDate(now.getDate() - 1);
          scheduledTask = new ToDoModel({
            title: "scheduled task",
            schedule: future
          });
          todoTask = new ToDoModel({
            title: "todo task",
            schedule: now
          });
          completedTask = new ToDoModel({
            title: "completed task",
            completionDate: past
          });
          return todos = new ToDoCollection([scheduledTask, todoTask, completedTask]);
        });
        it("getActive() should return all tasks to do right now", function() {
          return expect(todos.getActive().length).to.equal(1);
        });
        it("getScheduled() Should return all scheduled tasks", function() {
          return expect(todos.getScheduled().length).to.equal(1);
        });
        return it("getCompleted() Should return all completed tasks", function() {
          return expect(todos.getCompleted().length).to.equal(1);
        });
      });
    });
    require(["collection/ToDoCollection", "view/list/DesktopTask"], function(ToDoCollection, View) {
      return helpers.renderTodoList().then(function() {
        var list;
        list = contentHolder.find(".todo ol");
        (function() {
          var model, view;
          model = new ToDoModel(helpers.getDummyModels()[0]);
          view = new View({
            model: model
          });
          return describe("To Do View: Selecting", function() {
            list.append(view.el);
            view.$el.find(".todo-content").click();
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
              todos = new ToDoCollection(helpers.getDummyModels());
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
            it("Should get the 'hover-left' CSS class when 'hover-complete' event is triggered when selected", function() {
              var count, view, _i, _len;
              views[0].model.set("selected", true);
              views[1].model.set("selected", true);
              Backbone.trigger("hover-complete");
              count = 0;
              for (_i = 0, _len = views.length; _i < _len; _i++) {
                view = views[_i];
                if (view.$el.hasClass("hover-left")) {
                  count++;
                }
              }
              return expect(count).to.equal(2);
            });
            it("Should remove the 'hover-left' CSS class when 'unhover-complete' event is triggered when selected", function() {
              var count, view, _i, _len;
              views[0].model.set("selected", true);
              views[1].model.set("selected", true);
              views[0].$el.addClass("hover-complete");
              views[1].$el.addClass("hover-complete");
              Backbone.trigger("unhover-complete");
              count = 0;
              for (_i = 0, _len = views.length; _i < _len; _i++) {
                view = views[_i];
                if (view.$el.hasClass("hover-left")) {
                  count++;
                }
              }
              return expect(count).to.equal(0);
            });
            it("Should get the 'hover-right' CSS class when 'hover-schedule' event is triggered when selected", function() {
              var count, view, _i, _len;
              views[0].model.set("selected", true);
              views[1].model.set("selected", true);
              Backbone.trigger("hover-schedule");
              count = 0;
              for (_i = 0, _len = views.length; _i < _len; _i++) {
                view = views[_i];
                if (view.$el.hasClass("hover-right")) {
                  count++;
                }
              }
              return expect(count).to.equal(2);
            });
            return it("Should remove the 'hover-right' CSS class when 'unhover-schedule' event is triggered when selected", function() {
              var count, view, _i, _len;
              views[0].model.set("selected", true);
              views[1].model.set("selected", true);
              views[0].$el.addClass("hover-right");
              views[1].$el.addClass("hover-right");
              Backbone.trigger("unhover-schedule");
              count = 0;
              for (_i = 0, _len = views.length; _i < _len; _i++) {
                view = views[_i];
                if (view.$el.hasClass("hover-right")) {
                  count++;
                }
              }
              return expect(count).to.equal(0);
            });
          });
        })();
      });
    });
    require(["view/List", "model/ToDoModel"], function(ListView, ToDo) {
      var list;
      contentHolder.empty();
      list = new ListView();
      list.$el.appendTo(contentHolder);
      return describe("Base list view", function() {
        it("should add children when rendering", function() {
          return expect(list.$el.find("ol li")).to.have.length.above(0);
        });
        return it("Should remove all nested children as part of the cleanUp routine", function() {
          list.cleanUp();
          return expect(list.$el.find("ol li")).to.have.length.lessThan(1);
        });
      });
    });
    require(["view/Scheduled"], function(ScheduleView) {
      var laterToday, nextMonth, now, todos, tomorrow, view;
      laterToday = new Date();
      tomorrow = new Date();
      nextMonth = new Date();
      now = new Date();
      laterToday.setSeconds(now.getSeconds() + 1);
      tomorrow.setDate(now.getDate() + 1);
      nextMonth.setMonth(now.getMonth() + 1);
      todos = [
        new ToDoModel({
          title: "In a month",
          schedule: nextMonth
        }), new ToDoModel({
          title: "Tomorrow",
          schedule: tomorrow
        }), new ToDoModel({
          title: "In 1 hour",
          schedule: laterToday
        })
      ];
      view = new ScheduleView();
      return describe("Schedule list view", function() {
        return it("Should order tasks by chronological order", function() {
          var result;
          result = view.groupTasks(todos);
          expect(result[0].deadline).to.equal("Later today");
          return expect(result[1].deadline).to.equal("Tomorrow");
        });
      });
    });
    describe("To Do list view", function() {
      var todos, view;
      todos = view = null;
      before(function() {
        return todos = [
          new ToDoModel({
            title: "three"
          }), new ToDoModel({
            title: "two",
            order: 2
          }), new ToDoModel({
            title: "one",
            order: 1
          })
        ];
      });
      beforeEach(function(done) {
        return require(["view/Todo"], function(ToDoListView) {
          view = new ToDoListView();
          return setTimeout(done, 15);
        });
      });
      describe("Handling ToDoModel's order property", function() {
        it("Should have some tasks we can test with", function() {
          var models;
          expect(view).to.have.property("subviews");
          models = _.pluck(view.subviews, "model");
          return expect(models).to.have.length.above(0);
        });
        it("Should order tasks by models 'order' property", function() {
          var result;
          result = view.groupTasks(todos);
          expect(result[0].tasks[0].get("title")).to.equal("one");
          expect(result[0].tasks[1].get("title")).to.equal("two");
          return expect(result[0].tasks[2].get("title")).to.equal("three");
        });
        it("Should make sure no two todos have the same order id", function() {
          var list, newTasks, orders;
          list = [
            new ToDoModel({
              order: 0
            }), new ToDoModel({
              order: 0
            }), new ToDoModel({
              order: 2
            }), new ToDoModel({
              order: 5
            })
          ];
          newTasks = view.setTodoOrder(list);
          orders = _.invoke(newTasks, "get", "order");
          expect(orders).to.have.length(4);
          expect(orders).to.contain(0);
          expect(orders).to.contain(1);
          expect(orders).to.contain(2);
          return expect(orders).to.contain(3);
        });
        it("Should order todos by schdule date if no order is defined", function() {
          var first, firstModel, list, result, second, secondModel, third, thirdModel;
          first = new Date();
          second = new Date();
          third = new Date();
          second.setSeconds(second.getSeconds() + 1);
          third.setSeconds(third.getSeconds() + 2);
          list = [
            new ToDoModel({
              title: "third",
              schedule: third
            }), new ToDoModel({
              title: "second",
              schedule: second
            }), new ToDoModel({
              title: "first",
              schedule: first
            })
          ];
          result = view.setTodoOrder(list);
          firstModel = _.filter(result, function(m) {
            return m.get("title") === "first";
          })[0];
          secondModel = _.filter(result, function(m) {
            return m.get("title") === "second";
          })[0];
          thirdModel = _.filter(result, function(m) {
            return m.get("title") === "third";
          })[0];
          expect(result).to.have.length(3);
          expect(firstModel.get("order")).to.equal(0);
          expect(secondModel.get("order")).to.equal(1);
          return expect(thirdModel.get("order")).to.equal(2);
        });
        it("Should be able to mix in unordered and ordered items", function() {
          var first, firstModel, fourthModel, list, result, second, secondModel, thirdModel;
          first = new Date();
          second = new Date();
          second.setSeconds(second.getSeconds() + 1);
          list = [
            new ToDoModel({
              title: "third",
              schedule: second
            }), new ToDoModel({
              title: "first",
              schedule: first
            }), new ToDoModel({
              title: "second (has order)",
              order: 1
            }), new ToDoModel({
              title: "fourth (has order)",
              order: 3
            })
          ];
          result = view.setTodoOrder(list);
          firstModel = _.filter(result, function(m) {
            return m.get("title") === "first";
          })[0];
          secondModel = _.filter(result, function(m) {
            return m.get("title") === "second (has order)";
          })[0];
          thirdModel = _.filter(result, function(m) {
            return m.get("title") === "third";
          })[0];
          fourthModel = _.filter(result, function(m) {
            return m.get("title") === "fourth (has order)";
          })[0];
          expect(result).to.have.length(4);
          expect(firstModel.get("order")).to.equal(0);
          expect(secondModel.get("order")).to.equal(1);
          expect(thirdModel.get("order")).to.equal(2);
          return expect(fourthModel.get("order")).to.equal(3);
        });
        it("Should take models with order 3,4,5,6 and change them to 0,1,2,3", function() {
          var first, fourth, list, result, second, third;
          list = [
            new ToDoModel({
              title: "first",
              order: 3
            }), new ToDoModel({
              title: "second",
              order: 4
            }), new ToDoModel({
              title: "third",
              order: 5
            }), new ToDoModel({
              title: "fourth",
              order: 6
            })
          ];
          result = view.setTodoOrder(list);
          first = _.filter(result, function(m) {
            return m.get("title") === "first";
          })[0];
          second = _.filter(result, function(m) {
            return m.get("title") === "second";
          })[0];
          third = _.filter(result, function(m) {
            return m.get("title") === "third";
          })[0];
          fourth = _.filter(result, function(m) {
            return m.get("title") === "fourth";
          })[0];
          expect(result).to.have.length(4);
          expect(first.get("order")).to.equal(0);
          expect(second.get("order")).to.equal(1);
          expect(third.get("order")).to.equal(2);
          return expect(fourth.get("order")).to.equal(3);
        });
        it("Should take models with order 0,1,11,5 and change them to 0,1,2,3", function() {
          var first, fourth, list, result, second, third;
          list = [
            new ToDoModel({
              title: "first",
              order: 0
            }), new ToDoModel({
              title: "second",
              order: 1
            }), new ToDoModel({
              title: "third",
              order: 5
            }), new ToDoModel({
              title: "fourth",
              order: 11
            })
          ];
          result = view.setTodoOrder(list);
          first = _.filter(result, function(m) {
            return m.get("title") === "first";
          })[0];
          second = _.filter(result, function(m) {
            return m.get("title") === "second";
          })[0];
          third = _.filter(result, function(m) {
            return m.get("title") === "third";
          })[0];
          fourth = _.filter(result, function(m) {
            return m.get("title") === "fourth";
          })[0];
          expect(result).to.have.length(4);
          expect(first.get("order")).to.equal(0);
          expect(second.get("order")).to.equal(1);
          expect(third.get("order")).to.equal(2);
          return expect(fourth.get("order")).to.equal(3);
        });
        it("Should take models with order undefined,1,undefined,5 and change them to 0,1,2,3", function() {
          var first, fourth, list, result, second, third;
          list = [
            new ToDoModel({
              title: "first"
            }), new ToDoModel({
              title: "second",
              order: 1
            }), new ToDoModel({
              title: "third"
            }), new ToDoModel({
              title: "fourth",
              order: 5
            })
          ];
          result = view.setTodoOrder(list);
          first = _.filter(result, function(m) {
            return m.get("title") === "first";
          })[0];
          second = _.filter(result, function(m) {
            return m.get("title") === "second";
          })[0];
          third = _.filter(result, function(m) {
            return m.get("title") === "third";
          })[0];
          fourth = _.filter(result, function(m) {
            return m.get("title") === "fourth";
          })[0];
          expect(result).to.have.length(4);
          expect(first.get("order")).to.equal(0);
          expect(second.get("order")).to.equal(1);
          expect(third.get("order")).to.equal(2);
          return expect(fourth.get("order")).to.equal(3);
        });
        return it("Should take models with order 2,2,2,2 and change them to 0,1,2,3", function() {
          var first, fourth, list, result, second, third;
          list = [
            new ToDoModel({
              title: "first",
              order: 2
            }), new ToDoModel({
              title: "second",
              order: 2
            }), new ToDoModel({
              title: "jtown",
              order: 2
            }), new ToDoModel({
              title: "fourth",
              order: 2
            })
          ];
          result = view.setTodoOrder(list);
          first = _.filter(result, function(m) {
            return m.get("title") === "first";
          })[0];
          second = _.filter(result, function(m) {
            return m.get("title") === "second";
          })[0];
          third = _.filter(result, function(m) {
            return m.get("title") === "jtown";
          })[0];
          fourth = _.filter(result, function(m) {
            return m.get("title") === "fourth";
          })[0];
          expect(result).to.have.length(4);
          expect(first.get("order")).to.equal(0);
          expect(second.get("order")).to.equal(1);
          expect(third.get("order")).to.equal(2);
          return expect(fourth.get("order")).to.equal(3);
        });
      });
      describe("Handling order for new tasks", function() {
        return it("Should always put new tasks at the top", function(done) {
          Backbone.trigger("create-task", "number 1 for order testing");
          return setTimeout(function() {
            var m, newFirstModel, _i, _len, _ref;
            _ref = _.pluck(view.subviews, "model");
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              m = _ref[_i];
              if (m.get("order") === 0) {
                newFirstModel = m;
              }
            }
            expect(newFirstModel.get("title")).to.equal("number 1 for order testing");
            return done();
          }, 10);
        });
      });
      describe("Handling order for tasks moving from scheduled to active when their time is up", function() {
        before(function() {
          var oneMinAgo;
          oneMinAgo = new Date();
          oneMinAgo.setMinutes(oneMinAgo.getMinutes() - 1);
          swipy.todos.add({
            title: "one",
            schedule: oneMinAgo
          });
          swipy.todos.add({
            title: "two",
            schedule: oneMinAgo
          });
          return swipy.todos.add({
            title: "three",
            schedule: oneMinAgo
          });
        });
        beforeEach(function(done) {
          var future, models, now;
          now = new Date().getTime();
          models = swipy.todos.filter(function(m) {
            if (!m.has("schedule")) {
              return false;
            }
            return Math.abs(m.get("schedule").getTime() - now) < 5000;
          });
          if (models.length) {
            future = new Date();
            future.setSeconds(future.getSeconds() + 10);
            _.invoke(models, "set", {
              schedule: future
            });
          }
          return setTimeout(done, 50);
        });
        it("Should always put the tasks changed from scheduled to active at the top", function(done) {
          var future, lastModel, m, models, _i, _len;
          console.clear();
          models = _.pluck(view.subviews, "model");
          for (_i = 0, _len = models.length; _i < _len; _i++) {
            m = models[_i];
            if (m.get("order") === (models.length - 1)) {
              lastModel = m;
            }
          }
          future = new Date();
          future.setMilliseconds(future.getMilliseconds() + 100);
          lastModel.set("schedule", future);
          expect(swipy.todos.getActive()).to.have.length.below(models.length);
          return setTimeout(function() {
            view.moveTasksToActive();
            return setTimeout(function() {
              var newModels;
              newModels = _.pluck(view.subviews, "model");
              expect(newModels.length).to.be.above(1);
              expect(lastModel.get("order")).to.equal(0);
              return done();
            }, 50);
          }, 150);
        });
        return it("Should be able to handle multiple tasks changing at the same time", function(done) {
          var future;
          future = new Date();
          future.setMilliseconds(future.getMilliseconds() + 100);
          _.invoke(swipy.todos.getActive(), "set", {
            schedule: future
          });
          expect(swipy.todos.getActive()).to.have.length(0);
          return setTimeout(function() {
            Backbone.trigger("clockwork/update");
            return setTimeout(function() {
              return done();
            }, 50);
          }, 15);
        });
      });
      return describe("Handling order for tasks moving from completed to active", function() {
        beforeEach(function() {
          var future, models, now;
          now = new Date().getTime();
          models = swipy.todos.filter(function(m) {
            if (!m.has("schedule")) {
              return false;
            }
            return Math.abs(m.get("schedule").getTime() - now) < 5000;
          });
          if (models.length) {
            future = new Date();
            future.setSeconds(future.getSeconds() + 10);
            return _.invoke(models, "set", {
              schedule: future
            });
          }
        });
        it("Should always put the tasks changed from scheduled to active at the top", function(done) {
          var firstCompleted, veryRecent;
          swipy.todos.add({
            title: "dummy-completed-1",
            completionDate: new Date("11/10/2013")
          });
          swipy.todos.add({
            title: "dummy-completed-2",
            completionDate: new Date("11/10/2013")
          });
          swipy.todos.add({
            title: "dummy-completed-3",
            completionDate: new Date("11/10/2013")
          });
          firstCompleted = swipy.todos.getCompleted()[0];
          veryRecent = new Date();
          veryRecent.setMilliseconds(veryRecent.getMilliseconds() - 50);
          firstCompleted.set({
            completionDate: null,
            schedule: veryRecent
          });
          Backbone.trigger("clockwork/update");
          return setTimeout(function() {
            var firstNewModel, m, newModels, _i, _len;
            newModels = _.pluck(view.subviews, "model");
            for (_i = 0, _len = newModels.length; _i < _len; _i++) {
              m = newModels[_i];
              if (m.get("order") === 0) {
                firstNewModel = m;
              }
            }
            expect(firstNewModel.cid).to.equal(firstCompleted.cid);
            return done();
          }, 50);
        });
        return it("Should be able to handle multiple tasks changing at the same time", function(done) {
          var allCompleted;
          swipy.todos.add({
            title: "dummy-completed-4",
            completionDate: new Date("11/10/2013")
          });
          swipy.todos.add({
            title: "dummy-completed-5",
            completionDate: new Date("11/10/2013")
          });
          swipy.todos.add({
            title: "dummy-completed-6",
            completionDate: new Date("11/10/2013")
          });
          allCompleted = swipy.todos.getCompleted();
          expect(allCompleted.length).to.be.above(0);
          _.invoke(allCompleted, "set", {
            completionDate: null,
            schedule: allCompleted[0].getDefaultSchedule()
          });
          Backbone.trigger("clockwork/update");
          return setTimeout(function() {
            return done();
          }, 50);
        });
      });
    });
    require(["view/Completed"], function(CompletedView) {
      var earlierToday, now, prevMonth, todos, view, yesterday;
      earlierToday = new Date();
      yesterday = new Date();
      prevMonth = new Date();
      now = new Date();
      earlierToday.setSeconds(now.getSeconds() - 1);
      yesterday.setDate(now.getDate() - 1);
      prevMonth.setMonth(now.getMonth() - 1);
      todos = [
        new ToDoModel({
          title: "Last month",
          completionDate: prevMonth
        }), new ToDoModel({
          title: "Yesterday",
          completionDate: yesterday
        }), new ToDoModel({
          title: "An hour ago",
          completionDate: earlierToday
        })
      ];
      view = new CompletedView();
      return describe("Completed list view", function() {
        return it("Should order tasks by reverse chronological order", function() {
          var result;
          result = view.groupTasks(todos);
          expect(result[0].deadline).to.equal("Earlier today");
          return expect(result[1].deadline).to.equal("Yesterday");
        });
      });
    });
    describe("Schedule model", function() {
      var model, settings;
      model = settings = moment = null;
      beforeEach(function(done) {
        return require(["model/ScheduleModel", "model/SettingsModel"], function(ScheduleModel, SettingsModel) {
          model = new ScheduleModel();
          settings = new SettingsModel();
          moment = window.moment;
          return done();
        });
      });
      after(function() {
        return $(".overlay.scheduler").remove();
      });
      it("Should return a new date 3 hours in the future when scheduling for 'later today'", function() {
        var newDate, now, parsedNewDate, threeHoursInMs;
        now = moment();
        newDate = model.getDateFromScheduleOption("later today", now);
        expect(newDate).to.exist;
        parsedNewDate = moment(newDate);
        threeHoursInMs = 3 * 60 * 60 * 1000;
        return expect(parsedNewDate.diff(now)).to.equal(threeHoursInMs);
      });
      it("Should return a new date the same day at 18:00 when scheduling for 'this evening' (before 18.00)", function() {
        var newDate, parsedNewDate, today;
        today = moment();
        today.hour(17);
        newDate = model.getDateFromScheduleOption("this evening", today);
        expect(newDate).to.exist;
        parsedNewDate = moment(newDate);
        expect(parsedNewDate.hour()).to.equal(18);
        return expect(parsedNewDate.day()).to.equal(today.day());
      });
      it("Should set minutes and seconds to 0 when delaying a task to later today", function() {});
      it("Should return a new date the day after at 18:00 when scheduling for 'tomorrow evening' (after 18.00)", function() {
        var newDate, parsedNewDate, today;
        today = moment();
        today.hour(19);
        newDate = model.getDateFromScheduleOption("this evening", today);
        expect(newDate).to.exist;
        parsedNewDate = moment(newDate);
        expect(parsedNewDate.hour()).to.equal(18);
        return expect(parsedNewDate.dayOfYear()).to.equal(today.dayOfYear() + 1);
      });
      it("Should return a new date the day after at 09:00 when scheduling for 'tomorrow'", function() {
        var newDate, parsedNewDate, today;
        today = moment();
        newDate = model.getDateFromScheduleOption("tomorrow", today);
        expect(newDate).to.exist;
        parsedNewDate = moment(newDate);
        expect(parsedNewDate.dayOfYear()).to.equal(today.dayOfYear() + 1);
        return expect(parsedNewDate.hour()).to.equal(9);
      });
      it("Should return a new date 2 days from now at 09:00 when scheduling for 'day after tomorrow'", function() {
        var newDate, parsedNewDate, today;
        today = moment();
        newDate = model.getDateFromScheduleOption("day after tomorrow");
        expect(newDate).to.exist;
        parsedNewDate = moment(newDate);
        expect(parsedNewDate.dayOfYear()).to.equal(today.dayOfYear() + 2);
        return expect(parsedNewDate.hour()).to.equal(9);
      });
      it("Should return a new date this following saturday at 10:00 when scheduling for 'this weekend'", function() {
        var newDate, parsedNewDate, saturday;
        saturday = moment().endOf("week");
        saturday.day(6).hour(settings.get("snoozes").weekend.morning.hour);
        newDate = model.getDateFromScheduleOption("this weekend", saturday);
        expect(newDate).to.exist;
        parsedNewDate = moment(newDate);
        expect(parsedNewDate.day()).to.equal(6);
        expect(Math.floor(saturday.diff(parsedNewDate, "days", true))).to.equal(-7);
        return expect(parsedNewDate.hour()).to.equal(10);
      });
      it("Should return a new date this following monday at 9:00 when scheduling for 'next week'", function() {
        var monday, newDate, parsedNewDate;
        monday = moment().startOf("week");
        monday.day(1).hour(settings.get("snoozes").weekday.morning.hour);
        newDate = model.getDateFromScheduleOption("next week", monday);
        expect(newDate).to.exist;
        parsedNewDate = moment(newDate);
        expect(parsedNewDate.dayOfYear()).not.to.equal(monday.dayOfYear());
        expect(parsedNewDate.day()).to.equal(1);
        expect(Math.floor(monday.diff(parsedNewDate, "days", true))).to.equal(-7);
        return expect(parsedNewDate.hour()).to.equal(9);
      });
      it("Should return null when scheduling for 'unspecified'", function() {
        return expect(model.getDateFromScheduleOption("unspecified")).to.equal(null);
      });
      describe("converting time", function() {
        it("Should should not convert 'This evening' when it's before 18:00 hours", function() {
          return expect(model.getDynamicTime("This Evening", moment("2013-01-01 17:59"))).to.equal("This Evening");
        });
        it("Should convert 'This evening' to 'Tomorrow eve' when it's after 18:00 hours", function() {
          return expect(model.getDynamicTime("This Evening", moment("2013-01-01 18:00"))).to.equal("Tomorrow Eve");
        });
        it("Should convert 'Day After Tomorrow' to 'Wednesday' when we're on a monday", function() {
          var adjustedTime;
          adjustedTime = moment();
          adjustedTime.day("Monday");
          return expect(model.getDynamicTime("Day After Tomorrow", adjustedTime)).to.equal("Wednesday");
        });
        it("Should not convert 'This Weekend' when we're on a monday-friday", function() {
          var monday;
          monday = moment().day("Monday");
          return expect(model.getDynamicTime("This Weekend", monday)).to.equal("This Weekend");
        });
        return it("Should convert 'This Weekend' to 'Next Weekend' when we're on a saturday/sunday", function() {
          var saturday;
          saturday = moment().day("Saturday");
          return expect(model.getDynamicTime("This Weekend", saturday)).to.equal("Next Weekend");
        });
      });
      return describe("Rounding minutes and seconds", function() {
        it("Should not alter minutes and seconds when delaying a task to later today", function() {
          var newDate, now, parsedNewDate;
          now = moment().minute(23);
          newDate = model.getDateFromScheduleOption("later today", now);
          parsedNewDate = moment(newDate);
          expect(parsedNewDate.diff(now, "hours")).to.equal(3);
          return expect(parsedNewDate.minute()).to.equal(23);
        });
        it("Should set minutes and seconds to 0 when selecting 'this evening'", function() {
          var newDate, now, parsedNewDate;
          now = moment().hour(12).minute(23).second(23);
          newDate = model.getDateFromScheduleOption("this evening", now);
          parsedNewDate = moment(newDate);
          expect(parsedNewDate.hour()).to.equal(18);
          expect(parsedNewDate.minute()).to.equal(0);
          return expect(parsedNewDate.second()).to.equal(0);
        });
        it("Should set minutes and seconds to 0 when selecting 'tomorrow'", function() {
          var newDate, parsedNewDate;
          newDate = model.getDateFromScheduleOption("tomorrow", moment().minute(23).second(23));
          parsedNewDate = moment(newDate);
          expect(parsedNewDate.minute()).to.equal(0);
          return expect(parsedNewDate.second()).to.equal(0);
        });
        it("Should set minutes and seconds to 0 when selecting 'day after tomorrow'", function() {
          var newDate, parsedNewDate;
          newDate = model.getDateFromScheduleOption("day after tomorrow", moment().minute(23).second(23));
          parsedNewDate = moment(newDate);
          expect(parsedNewDate.minute()).to.equal(0);
          return expect(parsedNewDate.second()).to.equal(0);
        });
        it("Should set minutes and seconds to 0 when selecting 'this weekend'", function() {
          var newDate, parsedNewDate;
          newDate = model.getDateFromScheduleOption("this weekend", moment().minute(23).second(23));
          parsedNewDate = moment(newDate);
          expect(parsedNewDate.minute()).to.equal(0);
          return expect(parsedNewDate.second()).to.equal(0);
        });
        return it("Should set minutes and seconds to 0 when selecting 'next week'", function() {
          var newDate, parsedNewDate;
          newDate = model.getDateFromScheduleOption("next week", moment().minute(23).second(23));
          parsedNewDate = moment(newDate);
          expect(parsedNewDate.minute()).to.equal(0);
          return expect(parsedNewDate.second()).to.equal(0);
        });
      });
    });
    require(["controller/TaskInputController"], function(TaskInputController) {
      return describe("Task Input", function() {
        var callback, taskInput;
        taskInput = null;
        callback = null;
        before(function() {
          $("body").append("<form id='add-task'><input></form>");
          return taskInput = new TaskInputController();
        });
        after(function() {
          taskInput.view.remove();
          return taskInput = null;
        });
        describe("view", function() {
          it("Should not trigger a 'create-task' event when submitting input, if the input field is empty");
          return it("Should trigger a 'create-task' event when submitting actual input");
        });
        return describe("controller", function() {
          describe("parsing tags", function() {
            it("Should be able to add tasks without tags", function() {
              var model;
              taskInput.createTask("I love not using tags");
              model = swipy.todos.findWhere({
                title: "I love not using tags"
              });
              expect(model).to.exist;
              return expect(model.get("tags")).to.have.length(0);
            });
            it("Should be able to parse 1 tag", function() {
              var result;
              result = taskInput.parseTags("I love #tags");
              expect(result).to.have.length(1);
              return expect(result[0]).to.equal("tags");
            });
            it("Should be able to parse multiple tags", function() {
              var result;
              result = taskInput.parseTags("I love #tags, #racks, #stacks");
              expect(result).to.have.length(3);
              expect(result).to.include("tags");
              expect(result).to.include("racks");
              return expect(result).to.include("stacks");
            });
            it("Should be able to parse tags with spaces", function() {
              var result;
              result = taskInput.parseTags("I love #tags, #racks and stacks");
              expect(result).to.have.length(2);
              expect(result).to.include("tags");
              return expect(result).to.include("racks and stacks");
            });
            return it("Should be able to seperate tags without commas", function() {
              var result;
              result = taskInput.parseTags("I love #tags, #racks #stacks");
              expect(result).to.have.length(3);
              expect(result).to.include("tags");
              expect(result).to.include("racks");
              return expect(result).to.include("stacks");
            });
          });
          describe("parsing title", function() {
            it("Should not be able to add tags without a title", function() {
              var lengthAfter, lengthBefore;
              lengthBefore = swipy.todos.length;
              taskInput.createTask("#just a tag");
              lengthAfter = swipy.todos.length;
              return expect(lengthBefore).to.equal(lengthAfter);
            });
            it("Should parse title without including 1 tag", function() {
              var result;
              result = taskInput.parseTitle("I love #tags");
              return expect(result).to.equal("I love");
            });
            return it("Should parse title without including multiple tags", function() {
              var result;
              result = taskInput.parseTitle("I also love #tags, #rags");
              return expect(result).to.equal("I also love");
            });
          });
          return it("Should add a new item to swipy.todos list when create-task event is fired", function() {
            var model;
            Backbone.trigger("create-task", "Test task #tags, #rags");
            model = swipy.todos.findWhere({
              "title": "Test task"
            });
            expect(model).to.exist;
            expect(model.get("tags")).to.have.length(2);
            expect(model.get("tags")).to.include("tags");
            return expect(model.get("tags")).to.include("rags");
          });
        });
      });
    });
    require(["view/editor/TaskEditor"], function(TaskEditor) {
      return describe("Task Editor", function() {
        var editor, model, renderSpy;
        editor = renderSpy = null;
        model = new ToDoModel(helpers.getDummyModels()[0]);
        beforeEach(function() {
          renderSpy = sinon.spy(TaskEditor.prototype, "render");
          return editor = new TaskEditor({
            model: model
          });
        });
        afterEach(function() {
          TaskEditor.prototype.render.restore();
          if (editor != null) {
            editor.remove();
          }
          return editor = null;
        });
        it("Should pop up the scheduler when clicking scheduled time, so that the user can easily reschedule", function() {
          var schedulerTrigged;
          schedulerTrigged = false;
          Backbone.on("show-scheduler", function() {
            return schedulerTrigged = true;
          });
          editor.$el.find("time").click();
          return require(["view/scheduler/ScheduleOverlay"], function(ScheduleOverlayView) {
            return _.defer(function() {
              expect(schedulerTrigged).to.be["true"];
              return expect(swipy.scheduler.view.shown).to.be["true"];
            });
          });
        });
        it("Should re-render the HTML of the editor when the schedule is changed", function() {
          var future;
          expect(renderSpy).to.have.been.calledOnce;
          model.unset("schedule", {
            silent: true
          });
          future = new Date();
          future.setDate(future.getDate() + 1);
          model.set("schedule", future);
          return expect(renderSpy).to.have.been.calledTwice;
        });
        it("Should remain in the task editor after changing the schedule");
        it("Should set/clear the repeat option when picking one");
        return it("Should throw an error message if the changes can't be saved to the server");
      });
    });
    describe("Automatically moving tasks from scheduled to active", function() {
      var clock;
      clock = null;
      before(function(done) {
        return require(["model/ClockWork"], function(ClockWork) {
          clock = new ClockWork();
          return done();
        });
      });
      it("Should figure out the second count of the current minute and set a timer for the remaining seconds", function() {
        var now, secondsLeftThisMinute;
        now = new Date();
        secondsLeftThisMinute = 60 - now.getSeconds();
        expect(clock).to.have.property("timer");
        return expect(Math.round(clock.timeToNextTick())).to.equal(secondsLeftThisMinute);
      });
      it("Should disptach a 'clockwork/update' event when ClockWork.tick() is called (Once every minute)", function() {
        var eventTriggered;
        eventTriggered = false;
        Backbone.on("clockwork/update", function() {
          return eventTriggered = true;
        });
        clock.timer.progress(1);
        expect(clock.timesUpdated).to.equal(1);
        return expect(eventTriggered).to.be["true"];
      });
      it("Should spawn a new timer when the current one finishes", function() {
        clock.timer.progress(1);
        return expect(clock.timer.progress()).to.equal(0);
      });
      return it("Should handle time zone differences (So your desktop and phone will stay in sync if their time zones are off (Like when you just took the plane to a new time zone)");
    });
    describe("Repeating tasks", function() {
      describe("Repeat Picker user interface", function() {
        it("Should change the models repeatOption and repeatDate properties when clicking a repeat option", function(done) {
          var targetModel;
          targetModel = swipy.todos.getActive()[0];
          targetModel.set("repeatOption", "never");
          swipy.router.navigate("edit/" + targetModel.cid, true);
          return require(["view/editor/TaskEditor"], function() {
            var editor;
            expect(targetModel.get("repeatOption")).to.equal("never");
            expect(targetModel.get("repeatDate")).to.be.falsy;
            expect(targetModel.get("repeatCount")).to.equal(0);
            editor = swipy.viewController.currView.$el;
            editor.find(".repeat-picker a").filter(function() {
              return $(this).data("option") === "every day";
            }).click();
            expect(targetModel.get("repeatOption")).to.equal("every day");
            return done();
          });
        });
        return it("Should update the UI when the models repeatOption prop changes", function(done) {
          var targetModel;
          targetModel = swipy.todos.getActive()[0];
          targetModel.set("repeatOption", "never");
          swipy.router.navigate("edit/" + targetModel.cid, true);
          return require(["view/editor/TaskEditor"], function() {
            var editor;
            editor = swipy.viewController.currView.$el;
            targetModel.set("repeatOption", "every week");
            expect(editor.find("a[data-option='every week']").hasClass("selected")).to.be["true"];
            return done();
          });
        });
      });
      describe("Setting and changing repeat options on ToDo Model ", function() {
        var task;
        task = null;
        beforeEach(function() {
          return task = new ToDoModel();
        });
        afterEach(function() {
          return task.destroy();
        });
        it("Should create a repeatDate, if it doesn't already exist when the repeatOption is set to something other than 'never'", function() {
          expect(task.get("repeatDate")).to.be.falsy;
          task.set("repeatOption", "every day");
          return expect(task.get("repeatDate")).to.exist;
        });
        it("Should change the repeatDate, if it already exists when the repeatOption is set to something other than 'never'", function() {
          var originalRepeatDate;
          task.set("repeatOption", "every day");
          originalRepeatDate = task.get("repeatDate");
          task.set("repeatOption", "every week");
          return expect(originalRepeatDate.getTime()).to.not.equal(task.get("repeatDate").getTime());
        });
        return it("Should delete any existing repeatDate when setting repeatOption to 'never'", function() {
          task.set("repeatOption", "every day");
          task.set("repeatOption", "never");
          return expect(task.get("repeatDate")).to.be.falsy;
        });
      });
      describe("Duplicating tasks", function() {
        var duplicate, task;
        task = duplicate = null;
        beforeEach(function() {
          task = new ToDoModel({
            title: "test title",
            notes: "test notes",
            tags: ["tag1", "tag2"],
            order: 2,
            state: "completed",
            repeatOption: "every day"
          });
          task.set("completionDate", new Date());
          return duplicate = task.getRepeatableDuplicate();
        });
        afterEach(function() {
          task.destroy();
          return duplicate.destroy();
        });
        it("Shouldn't allow you to create a duplicate, if the task has no repeatDate", function() {
          return expect(new ToDoModel().getRepeatableDuplicate).to["throw"](Error);
        });
        it("Should return a new instance of ToDo Model when calling 'getRepeatableDuplicate()'", function() {
          expect(task).to.respondTo("getRepeatableDuplicate");
          return expect(duplicate).to.be.instanceOf(ToDoModel);
        });
        it("Should retain title when duplicating a task", function() {
          expect(task.get("title")).to.have.length.above(0);
          return expect(task.get("title")).to.equal(duplicate.get("title"));
        });
        it("Should retain tags when duplicating a task", function() {
          expect(task.get("tags")).to.have.length.above(0);
          return expect(task.get("tags")).to.have.length(duplicate.get("tags").length);
        });
        it("Should retain notes when duplicating a task", function() {
          expect(task.get("notes")).to.have.length.above(0);
          return expect(task.get("notes")).to.equal(duplicate.get("notes"));
        });
        it("Should retain order when duplicating a task", function() {
          expect(task.get("order")).to.not.be.falsy;
          return expect(task.get("order")).to.equal(duplicate.get("order"));
        });
        it("Should retain repeatOption when duplicating a task", function() {
          return expect(task.get("repeatOption")).to.equal(duplicate.get("repeatOption"));
        });
        it("Should NOT retain state when duplicating a task", function() {
          expect(duplicate.has("state")).to.be["false"];
          return expect(duplicate.getState()).to.equal("scheduled");
        });
        it("Should NOT retain model ID when duplicating a task", function() {
          if (task.id != null) {
            return expect(duplicate.id).to.not.exist;
          }
        });
        it("Should NOT retain schedule when duplicating a task", function() {
          expect(duplicate.has("schedule")).to.be["true"];
          return expect(task.get("schedule").getTime()).to.not.equal(duplicate.get("schedule").getTime());
        });
        it("Should NOT retain scheduleStr when duplicating a task", function() {
          expect(duplicate.has("scheduleStr")).to.be["true"];
          return expect(task.get("scheduleStr")).to.not.equal(duplicate.get("scheduleStr"));
        });
        it("Should NOT retain completionDate when duplicating a task", function() {
          return expect(duplicate.has("completionDate")).to.be["false"];
        });
        it("Should NOT retain completionStr when duplicating a task", function() {
          return expect(duplicate.has("completionStr")).to.be["false"];
        });
        it("Should NOT retain completionTimeStr when duplicating a task", function() {
          return expect(duplicate.has("completionTimeStr")).to.be["false"];
        });
        it("Should NOT retain repeatDate when duplicating a task", function() {
          expect(duplicate.has("repeatDate")).to.be["true"];
          return expect(task.get("repeatDate").getTime()).to.not.equal(duplicate.get("repeatDate").getTime());
        });
        it("Should NOT retain repeatCount when duplicating a task", function() {
          expect(task.has("repeatCount")).to.be["true"];
          expect(duplicate.has("repeatCount")).to.be["true"];
          return expect(task.get("repeatCount")).to.not.equal(duplicate.get("repeatCount"));
        });
        return it("Should update repeatCount++ every time a the same task is duplicated/repeated", function() {
          return expect(duplicate.get("repeatCount")).to.equal(task.get("repeatCount") + 1);
        });
      });
      describe("Duplicating a task based on repeatDate and repeatOption", function() {
        var task;
        task = null;
        beforeEach(function() {
          return task = new ToDoModel({
            title: "test repeated every day"
          });
        });
        afterEach(function() {
          return task.destroy();
        });
        describe("Repeat option: 'every day' — Scheduled for 11/11/2013", function() {
          beforeEach(function() {
            return task.set({
              repeatOption: "every day",
              schedule: new Date("11/11/2013")
            });
          });
          it("Should schedule duplicated task for 11/12/2013, if current task is completed 11/11/2013", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/11/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(12);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          it("Should schedule duplicated task for 11/13/2013, if current task is completed 11/12/2013 (Completed one day too late)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/12/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(13);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          it("Should schedule duplicated task for 11/12/2013, if current task is completed 11/09/2013 (Completed too early, don't create new repeat before scheduled repeatDate)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/09/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(task.get("schedule").getTime()).to.equal(new Date("11/11/2013").getTime());
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(12);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          return it("Should schedule duplicated task for 01/23/2014, if current task is completed 01/22/2014 (Completed much too late)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("01/22/2014"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(0);
            expect(newSchedule.getDate()).to.equal(23);
            return expect(newSchedule.getFullYear()).to.equal(2014);
          });
        });
        describe("Repeat option: 'mon-fri or sat+sun'", function() {
          beforeEach(function() {
            return task.set({
              repeatOption: "mon-fri or sat+sun",
              schedule: new Date("11/11/2013")
            });
          });
          it("should schedule duplicated task for tuesday 11/12/2013 if scheduled for monday 11/11/2013, but completed sunday 11/10/2013 (Too early)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/10/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(12);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          it("should schedule duplicated task for monday 11/18/2013 if completed friday 11/15/2013, but scheduled for monday 11/11/2013 (Too late)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/15/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(18);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          it("should schedule duplicated task for tuesday 11/12/2013 if completed and scheduled for monday 11/11/2013 (On time)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/11/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(12);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          it("should schedule duplicated task for saturday 11/16/2013 if scheduled for sunday 11/10/2013, but completed sunday 11/03/2013 (A week too early)", function() {
            var duplicate, newSchedule, newTask;
            newTask = new ToDoModel({
              repeatOption: "mon-fri or sat+sun",
              schedule: new Date("11/10/2013")
            });
            newTask.set("completionDate", new Date("11/03/2013"));
            duplicate = newTask.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(16);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          it("should schedule duplicated task for saturday 11/16/2013 if completed sunday 11/10/2013, but scheduled for monday 11/03/2013 (A week too late)", function() {
            var duplicate, newSchedule, newTask;
            newTask = new ToDoModel({
              repeatOption: "mon-fri or sat+sun",
              schedule: new Date("11/03/2013")
            });
            newTask.set("completionDate", new Date("11/10/2013"));
            duplicate = newTask.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(16);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          it("should schedule duplicated task for sunday 11/10/2013 if completed and scheduled for saturday 11/09/2013 (On time)", function() {
            var duplicate, newSchedule, newTask;
            newTask = new ToDoModel({
              repeatOption: "mon-fri or sat+sun",
              schedule: new Date("11/09/2013")
            });
            newTask.set("completionDate", new Date("11/09/2013"));
            duplicate = newTask.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(10);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          return it("should schedule duplicated task for saturday 11/16/2013 if completed and scheduled for sunday 11/10/2013 (On time)", function() {
            var duplicate, newSchedule, newTask;
            newTask = new ToDoModel({
              repeatOption: "mon-fri or sat+sun",
              schedule: new Date("11/10/2013")
            });
            newTask.set("completionDate", new Date("11/10/2013"));
            duplicate = newTask.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(16);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
        });
        describe("Repeat option: 'every week'", function() {
          beforeEach(function() {
            return task.set({
              repeatOption: "every week",
              schedule: new Date("11/12/2013")
            });
          });
          it("should schedule duplicated task for tuesday 11/19/2013 if current task is scheduled for and completed 11/12/2013 (on time)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/12/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(19);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          it("should still schedule duplicated task for tuesday 11/19/2013 if current task is scheduled for 11/12/2013 but completed 11/13/2013 (wednesday, the day after)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/13/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(19);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          it("should schedule duplicated task for tuesday 11/19/2013 if current task is scheduled for 11/12/2013 but completed 11/18/2013 (monday, the week after original schedule date)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/18/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(19);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          return it("should schedule duplicated task for tuesday 11/26/2013 if current task is scheduled for 11/12/2013 but completed wednesday 11/20/2013 (1 week and 1 day after original schedule date)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/20/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(26);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
        });
        describe("Repeat option: 'every month'", function() {
          beforeEach(function() {
            return task.set({
              repeatOption: "every month",
              schedule: new Date("10/18/2013")
            });
          });
          it("Should schedule duplicate for 11/18/2013, if scheduled for and completed on 10/18/2013 (On time)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("10/18/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(18);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          it("Should schedule duplicate for 11/18/2013, if scheduled for 10/18/2013 and completed on 11/17/2013 (less than 1 month late)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/17/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(18);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          it("Should schedule duplicate for 12/18/2013, if scheduled for 10/18/2013 and completed on 11/19/2013 (more than 1 month late)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/19/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(11);
            expect(newSchedule.getDate()).to.equal(18);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
          return it("Should schedule duplicate for 11/30/2013, if scheduled for and completed on 10/31/2013 (Handling difference between number of days in a month nicely)", function() {
            var duplicate, newSchedule, newTask;
            newTask = new ToDoModel({
              repeatOption: "every month",
              schedule: new Date("10/31/2013")
            });
            newTask.set("completionDate", new Date("10/31/2013"));
            duplicate = newTask.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(30);
            return expect(newSchedule.getFullYear()).to.equal(2013);
          });
        });
        return describe("Repeat option: 'every year'", function() {
          beforeEach(function() {
            return task.set({
              repeatOption: "every year",
              schedule: new Date("11/18/2013")
            });
          });
          it("Should schedule duplicate for 11/18/2014, if scheduled for and completed on 11/18/2013 (On time)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/18/2013"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(18);
            return expect(newSchedule.getFullYear()).to.equal(2014);
          });
          it("Should schedule duplicate for 11/18/2014, if scheduled for 11/18/2013 and completed on 11/17/2014 (less than 1 year late)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/17/2014"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(18);
            return expect(newSchedule.getFullYear()).to.equal(2014);
          });
          it("Should schedule duplicate for 11/18/2015, if scheduled for 11/18/2013 and completed on 11/19/2014 (more than 1 year late)", function() {
            var duplicate, newSchedule;
            task.set("completionDate", new Date("11/19/2014"));
            duplicate = task.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(10);
            expect(newSchedule.getDate()).to.equal(18);
            return expect(newSchedule.getFullYear()).to.equal(2015);
          });
          return it("if repeatDate is only existant because of a leap year (for instance 02/29/2016), we should schedule for the day before the next year (02/28/2017)", function() {
            var duplicate, newSchedule, newTask;
            newTask = new ToDoModel({
              repeatOption: "every year",
              schedule: new Date("02/29/2016")
            });
            newTask.set("completionDate", new Date("02/29/2016"));
            duplicate = newTask.getRepeatableDuplicate();
            newSchedule = duplicate.get("schedule");
            expect(newSchedule.getMonth()).to.equal(1);
            expect(newSchedule.getDate()).to.equal(28);
            return expect(newSchedule.getFullYear()).to.equal(2017);
          });
        });
      });
      describe("Un-setting repeat options on ToDo Model", function() {
        it("Should change repeatDate to 'null' of repeatOption is set to 'never'", function() {
          var task;
          task = new ToDoModel({
            repeatOption: "every week"
          });
          expect(task.get("repeatDate")).to.be.instanceOf(Date);
          task.set("repeatOption", "never");
          return expect(task.get("repeatDate")).to.equal(null);
        });
        return it("Should delete duplicated (repeated) tasks when repeatOption is set to 'never'");
      });
      return describe("Completing a task with repeat set and automatically spawning a new task", function() {
        it("TodoCollection should listen for tasks that are completed and spawn a duplicate if repeatOption is anything but 'never'", function(done) {
          return require(["collection/ToDoCollection"], function(ToDoCollection) {
            var spawnSpy, todoCollection;
            spawnSpy = sinon.spy(ToDoCollection.prototype, "spawnRepeatTask");
            expect(spawnSpy).to.not.have.been.called;
            todoCollection = new ToDoCollection();
            todoCollection.add({
              title: "auto spawn tester",
              repeatOption: "every day"
            });
            expect(todoCollection.models).to.have.length(1);
            todoCollection.at(0).set("completionDate", new Date());
            expect(spawnSpy).to.have.been.calledOnce;
            expect(todoCollection.models).to.have.length(2);
            ToDoCollection.prototype.spawnRepeatTask.restore();
            todoCollection.off();
            todoCollection = null;
            return done();
          });
        });
        return it("TodoCollection should listen for tasks that are completed and do nothing if repeatOption is 'never'", function(done) {
          return require(["collection/ToDoCollection"], function(ToDoCollection) {
            var spawnSpy, todoCollection;
            spawnSpy = sinon.spy(ToDoCollection.prototype, "spawnRepeatTask");
            todoCollection = new ToDoCollection();
            todoCollection.add({
              title: "auto spawn tester 2"
            });
            todoCollection.at(0).set("completionDate", new Date());
            expect(spawnSpy).to.have.been.calledOnce;
            expect(todoCollection.models).to.have.length(1);
            ToDoCollection.prototype.spawnRepeatTask.restore();
            todoCollection.off();
            todoCollection = null;
            return done();
          });
        });
      });
    });
    describe("Tag Filter", function() {
      beforeEach(function() {
        Backbone.trigger("create-task", "TagTester1 #Nina");
        Backbone.trigger("create-task", "TagTester2 #Nina, #Pinta");
        return Backbone.trigger("create-task", "TagTester3 #Nina, #Pinta, #Santa-Maria");
      });
      afterEach(function() {
        swipy.todos.findWhere({
          title: "TagTester1"
        }).destroy();
        swipy.todos.findWhere({
          title: "TagTester2"
        }).destroy();
        return swipy.todos.findWhere({
          title: "TagTester3"
        }).destroy();
      });
      it("Should add new tags to the global tags collection", function() {
        swipy.sidebar.tagFilter.addTag("My Test Tag zyxvy");
        return expect(swipy.tags.pluck("title")).to.include("My Test Tag zyxvy");
      });
      it("Should re-render whenever tags in the global collection are added or removed", function() {
        return require(["view/sidebar/TagFilter"], function(TagFilter) {
          var dummyTitle, filter, renderSpy;
          renderSpy = sinon.spy(TagFilter.prototype, "render");
          filter = new TagFilter({
            el: $(".sidebar .tags-filter")
          });
          expect(renderSpy).to.have.been.calledOnce;
          dummyTitle = "dummy-" + new Date().getTime();
          swipy.tags.add({
            title: dummyTitle
          });
          expect(renderSpy).to.have.been.calledTwice;
          swipy.tags.remove(swipy.tags.findWhere({
            title: dummyTitle
          }));
          expect(renderSpy).to.have.been.calledThrice;
          TagFilter.prototype.render.restore();
          filter.remove();
          return $(".sidebar").append("<section class='tags-filter'><ul class='rounded-tags'></ul></section>");
        });
      });
      it("Should show all tags again if the last tag is de-selected", function(done) {
        return require(["view/sidebar/TagFilter"], function(TagFilter) {
          var filter, origTagCount, renderSpy, savedRender;
          savedRender = swipy.sidebar.tagFilter.__proto__.render;
          swipy.sidebar.tagFilter.render = function() {};
          renderSpy = sinon.spy(TagFilter.prototype, "render");
          filter = new TagFilter({
            el: $(".sidebar .tags-filter")
          });
          expect(renderSpy).to.have.been.calledOnce;
          origTagCount = filter.$el.find("li:not(.tag-input)").length;
          Backbone.trigger("apply-filter", "tag", "Santa-Maria");
          Backbone.trigger("remove-filter", "tag", "Santa-Maria");
          return _.defer(function() {
            var tag, tags;
            expect(renderSpy).to.have.been.calledThrice;
            tags = (function() {
              var _i, _len, _ref, _results;
              _ref = filter.$el.find("li:not(.tag-input)");
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                tag = _ref[_i];
                _results.push($(tag).text());
              }
              return _results;
            })();
            expect(tags).to.have.length(origTagCount);
            TagFilter.prototype.render.restore();
            filter.remove();
            $(".sidebar").append("<section class='tags-filter'><ul class='rounded-tags'></ul></section>");
            swipy.sidebar.tagFilter.render = savedRender;
            return done();
          });
        });
      });
      describe("Filtering tasks", function() {
        return it("If one or more tags are selected, it should only show the tasks that has all of those filters", function() {
          var tagTitles, taskTitles;
          taskTitles = swipy.todos.pluck("title");
          expect(taskTitles).to.include("TagTester1");
          expect(taskTitles).to.include("TagTester2");
          expect(taskTitles).to.include("TagTester3");
          tagTitles = swipy.tags.pluck("title");
          expect(tagTitles).to.include("Nina");
          expect(tagTitles).to.include("Pinta");
          expect(tagTitles).to.include("Santa-Maria");
          Backbone.trigger("apply-filter", "tag", "Nina");
          expect(swipy.todos.where({
            rejectedByTag: false
          })).to.have.length(3);
          Backbone.trigger("apply-filter", "tag", "Pinta");
          expect(swipy.todos.where({
            rejectedByTag: false
          })).to.have.length(2);
          expect(swipy.todos.findWhere({
            title: "TagTester1"
          }).get("rejectedByTag")).to.be["true"];
          Backbone.trigger("apply-filter", "tag", "Santa-Maria");
          expect(swipy.todos.where({
            rejectedByTag: false
          })).to.have.length(1);
          return expect(swipy.todos.findWhere({
            title: "TagTester2"
          }).get("rejectedByTag")).to.be["true"];
        });
      });
      return describe("Narrowing down available tags after filtering", function() {
        return it("If one or more tags are selected, it should only show those remaining tags that will allow you to do a deeper filter. No tag should ever leed to 0 results when selected.", function(done) {
          return require(["view/sidebar/TagFilter"], function(TagFilter) {
            var filter, renderSpy, savedRender;
            savedRender = swipy.sidebar.tagFilter.__proto__.render;
            swipy.sidebar.tagFilter.render = function() {};
            renderSpy = sinon.spy(TagFilter.prototype, "render");
            filter = new TagFilter({
              el: $(".sidebar .tags-filter")
            });
            expect(renderSpy).to.have.been.calledOnce;
            Backbone.trigger("apply-filter", "tag", "Nina");
            return _.defer(function() {
              var tag, tags;
              expect(renderSpy).to.have.been.calledTwice;
              tags = (function() {
                var _i, _len, _ref, _results;
                _ref = filter.$el.find("li:not(.tag-input)");
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  tag = _ref[_i];
                  _results.push($(tag).text());
                }
                return _results;
              })();
              expect(tags).to.have.length(3);
              expect(tags).to.contain("Nina");
              expect(tags).to.contain("Pinta");
              expect(tags).to.contain("Santa-Maria");
              Backbone.trigger("apply-filter", "tag", "Pinta");
              return _.defer(function() {
                tags = (function() {
                  var _i, _len, _ref, _results;
                  _ref = filter.$el.find("li:not(.tag-input)");
                  _results = [];
                  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                    tag = _ref[_i];
                    _results.push($(tag).text());
                  }
                  return _results;
                })();
                expect(tags).to.have.length(3);
                expect(tags).to.contain("Nina");
                expect(tags).to.contain("Pinta");
                expect(tags).to.contain("Santa-Maria");
                Backbone.trigger("remove-filter", "tag", "Nina");
                Backbone.trigger("apply-filter", "tag", "Santa-Maria");
                return _.defer(function() {
                  expect(swipy.filter.tagsFilter).to.have.length(2);
                  expect(swipy.filter.tagsFilter).to.contain("Pinta");
                  expect(swipy.filter.tagsFilter).to.contain("Santa-Maria");
                  tags = (function() {
                    var _i, _len, _ref, _results;
                    _ref = filter.$el.find("li:not(.tag-input)");
                    _results = [];
                    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                      tag = _ref[_i];
                      _results.push($(tag).text());
                    }
                    return _results;
                  })();
                  expect(tags).to.have.length(3);
                  expect(tags).to.contain("Nina");
                  expect(tags).to.contain("Pinta");
                  expect(tags).to.contain("Santa-Maria");
                  Backbone.trigger("apply-filter", "tag", "Nina");
                  return _.defer(function() {
                    expect(swipy.filter.tagsFilter).to.have.length(3);
                    expect(swipy.filter.tagsFilter).to.contain("Nina");
                    expect(swipy.filter.tagsFilter).to.contain("Pinta");
                    expect(swipy.filter.tagsFilter).to.contain("Santa-Maria");
                    tags = (function() {
                      var _i, _len, _ref, _results;
                      _ref = filter.$el.find("li:not(.tag-input)");
                      _results = [];
                      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                        tag = _ref[_i];
                        _results.push($(tag).text());
                      }
                      return _results;
                    })();
                    expect(tags).to.have.length(3);
                    expect(tags).to.contain("Nina");
                    expect(tags).to.contain("Pinta");
                    expect(tags).to.contain("Santa-Maria");
                    TagFilter.prototype.render.restore();
                    filter.remove();
                    $(".sidebar").append("<section class='tags-filter'><ul class='rounded-tags'></ul></section>");
                    swipy.sidebar.tagFilter.render = savedRender;
                    return done();
                  });
                });
              });
            });
          });
        });
      });
    });
    require(["view/list/TagEditorOverlay"], function(TagEditorOverlay) {
      return describe("Tag Editor overlay", function() {
        describe("Marking shared tags selected", function() {
          it("Should detect if any tasks have no tags", function() {
            var d, data, models, overlay;
            data = helpers.getDummyModels();
            models = (function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = data.length; _i < _len; _i++) {
                d = data[_i];
                _results.push(new ToDoModel(d));
              }
              return _results;
            })();
            models[0].unset("tags");
            overlay = new TagEditorOverlay({
              models: models
            });
            return expect(overlay.getTagsAppliedToAll()).to.have.length(0);
          });
          return it("Should detect if any tags are shared between the selected tasks", function() {
            var d, data, models, overlay;
            data = [
              {
                title: "Task 1",
                tags: ["tag1", "tag2"]
              }, {
                title: "Task 2",
                tags: ["tag2"]
              }, {
                title: "Task 3",
                tags: ["tag2", "tag3"]
              }
            ];
            models = (function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = data.length; _i < _len; _i++) {
                d = data[_i];
                _results.push(new ToDoModel(d));
              }
              return _results;
            })();
            overlay = new TagEditorOverlay({
              models: models
            });
            return expect(overlay.getTagsAppliedToAll()).to.have.length(1);
          });
        });
        return describe("Handling interaction / Updating models", function() {
          it("Should detect if clicked tag is currently selected");
          it("Should remove clicked tag from all tasks if clicked tag is marked selected");
          it("Should add clicked tag to all tasks unless tag is marked selected");
          return it("Should add new tag to all selected tasks if a new tag is created");
        });
      });
    });
    return describe("Router", function() {
      before(function() {
        location.hash = "";
        return swipy.router.route("test/reset", "reset test", function() {});
      });
      beforeEach(function() {
        location.hash = "test/reset";
        return swipy.router.history = [];
      });
      after(function(done) {
        swipy.router.once("route:root", function() {
          return done();
        });
        location.hash = "test/reset";
        return location.hash = "";
      });
      it("Should make sure everything is reset before we start testing routes", function() {
        return expect(swipy.settings.view).to.be.undefined;
      });
      it("Should trigger appropiate logic when navigating to 'settings'", function(done) {
        var eventTriggered,
          _this = this;
        eventTriggered = false;
        Backbone.once("show-settings", function() {
          return eventTriggered = true;
        });
        location.hash = "settings";
        return _.defer(function() {
          expect(eventTriggered).to.be["true"];
          return setTimeout(function() {
            expect(swipy.settings.view).to.have.property("shown", true);
            return done();
          }, 500);
        });
      });
      it("Should should not open any settings sub view when just navigating to 'settings'", function() {
        return expect(swipy.settings.view.subview).to.not.exist;
      });
      it("Should trigger appropiate logic when navigating to 'settings/:-id'", function(done) {
        var eventTriggered,
          _this = this;
        eventTriggered = false;
        Backbone.once("show-settings", function() {
          return eventTriggered = true;
        });
        location.hash = "settings/faq";
        _.defer(function() {
          expect(eventTriggered).to.be["true"];
          return expect(swipy.settings.view).to.have.property("shown", true);
        });
        return setTimeout(function() {
          expect(swipy.settings.view.subview).to.exist;
          expect(swipy.settings.view.subview.$el.hasClass("faq")).to.be["true"];
          return done();
        }, 150);
      });
      it("Should trigger appropiate logic when navigating to 'list/:id'", function(done) {
        var eventTriggered,
          _this = this;
        eventTriggered = false;
        Backbone.once("navigate/view", function(id) {
          if (id === "scheduled") {
            return eventTriggered = true;
          }
        });
        location.hash = "list/scheduled";
        _.defer(function() {
          return expect(eventTriggered).to.be["true"];
        });
        return require(["view/Scheduled"], function(ScheduledListView) {
          return setTimeout(function() {
            expect(swipy.viewController.currView).to.exist;
            expect(swipy.viewController.currView).to.be.instanceOf(ScheduledListView);
            return done();
          }, 150);
        });
      });
      it("Should trigger appropiate logic when navigating to 'edit/:id'", function(done) {
        var eventTriggered, testTaskId,
          _this = this;
        testTaskId = swipy.todos.at(0).cid;
        eventTriggered = false;
        Backbone.once("edit/task", function(id) {
          if (id === testTaskId) {
            return eventTriggered = true;
          }
        });
        location.hash = "edit/" + testTaskId;
        _.defer(function() {
          return expect(eventTriggered).to.be["true"];
        });
        return require(["view/editor/TaskEditor"], function(TaskEditor) {
          return setTimeout(function() {
            expect(swipy.viewController.currView).to.exist;
            expect(swipy.viewController.currView).to.be.instanceOf(TaskEditor);
            return done();
          }, 150);
        });
      });
      it("Should go back to list view when calling save on task editor", function(done) {
        location.hash = "list/todo";
        return _.defer(function() {
          var editTaskRoute;
          editTaskRoute = "edit/" + (swipy.todos.at(1).cid);
          location.hash = editTaskRoute;
          return require(["view/editor/TaskEditor", "view/Todo"], function(TaskEditor, TodoList) {
            return setTimeout(function() {
              var editor;
              editor = swipy.viewController.currView;
              expect(swipy.router.history).to.have.length(2);
              expect(editor).to.be.instanceOf(TaskEditor);
              expect($("body").hasClass("edit-mode")).to.be["true"];
              return editor.save().then(function() {
                return setTimeout(function() {
                  var newRoute;
                  newRoute = location.hash.slice(1);
                  expect(newRoute).to.not.equal(editTaskRoute);
                  expect(swipy.viewController.currView).to.exist;
                  expect(Backbone.history.fragment).to.equal("list/todo");
                  expect(swipy.viewController.currView).to.be.instanceOf(TodoList);
                  expect($("body").hasClass("edit-mode")).to.be["false"];
                  return done();
                }, 150);
              });
            }, 500);
          });
        });
      });
      it("Should have a catch-all which results in 'list/todo'", function() {
        var eventTriggered,
          _this = this;
        eventTriggered = false;
        Backbone.once("navigate/view", function(id) {
          if (id === "todo") {
            return eventTriggered = true;
          }
        });
        location.hash = "random/jibberish";
        return _.defer(function() {
          return expect(eventTriggered).to.be["true"];
        });
      });
      return it("The router should have a custom history lookup, so we can call swipy.router.back() and make sure not to go outside our current domain, unlike history.back in the browser", function(done) {
        var i, lastRouteDfd, route, routerTriggeredTimes, testRoutes, _fn, _i, _len;
        expect(swipy.router).to.respondTo("back");
        expect(swipy.router).to.have.property("history");
        lastRouteDfd = new $.Deferred();
        routerTriggeredTimes = 0;
        Backbone.on("navigate/view edit/task show-settings", function() {
          return routerTriggeredTimes++;
        });
        testRoutes = ["", "list/scheduled", "edit/" + (swipy.todos.at(0).cid), "list/scheduled", "list/completed", "", "settings"];
        _fn = function() {
          var count, path;
          count = i;
          path = route;
          return setTimeout(function() {
            if (count === 0) {
              swipy.router.history = [];
            }
            location.hash = path;
            if (count === testRoutes.length - 1) {
              return setTimeout(lastRouteDfd.resolve, 100);
            }
          }, i * 200);
        };
        for (i = _i = 0, _len = testRoutes.length; _i < _len; i = ++_i) {
          route = testRoutes[i];
          _fn();
        }
        return lastRouteDfd.promise().done(function() {
          var fixRoute;
          expect(routerTriggeredTimes).to.equal(testRoutes.length);
          expect(swipy.router.history).to.have.length(testRoutes.length);
          fixRoute = function(route) {
            if (route === "") {
              return "list/todo";
            } else {
              return route;
            }
          };
          expect(location.hash).to.equal("#" + fixRoute(testRoutes[testRoutes.length - 1]));
          window.dontdontstopmenow = true;
          swipy.router.back();
          expect(location.hash).to.equal("#" + fixRoute(testRoutes[testRoutes.length - 2]));
          swipy.router.back();
          expect(Backbone.history.fragment).to.equal(fixRoute(testRoutes[testRoutes.length - 3]));
          return done();
        });
      });
    });
  });

}).call(this);
