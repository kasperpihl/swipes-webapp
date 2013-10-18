(function() {
  define(["jquery", "underscore", "backbone", "model/ToDoModel"], function($, _, Backbone, ToDoModel) {
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
            tags: ["work", "client"],
            notes: ""
          }, {
            title: "Completed Dummy task #3",
            order: 2,
            schedule: new Date(),
            completionDate: new Date("July 12, 2013 11:51:45"),
            repeatOption: "never",
            repeatDate: null,
            tags: ["work", "client"],
            notes: ""
          }, {
            title: "Dummy task #2",
            order: 1,
            schedule: future,
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
    describe("List Item model", function() {
      var model;
      model = new ToDoModel();
      it("Should create scheduleStr property when instantiated", function() {
        return expect(model.get("scheduleStr")).to.equal("the past");
      });
      it("Should update scheduleStr when schedule property is changed", function() {
        var date;
        date = model.get("schedule");
        model.unset("schedule");
        date.setDate(date.getDate() + 1);
        model.set("schedule", date);
        return expect(model.get("scheduleStr")).to.equal("Tomorrow");
      });
      it("Should create timeStr property when model is instantiated", function() {
        return expect(model.get("timeStr")).to.exist;
      });
      it("Should update timeStr when schedule property is changed", function() {
        var date, timeAfterChange, timeBeforeChange;
        timeBeforeChange = model.get("timeStr");
        date = model.get("schedule");
        model.unset("schedule");
        date.setHours(date.getHours() - 1);
        model.set("schedule", date);
        timeAfterChange = model.get("timeStr");
        return expect(timeBeforeChange).to.not.equal(timeAfterChange);
      });
      return it("Should update completedStr when completionDate is changed", function() {
        model.set("completionDate", new Date());
        expect(model.get("completionStr")).to.exist;
        return expect(model.get("completionTimeStr")).to.exist;
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
    /*
    	require ["view/List", "model/ToDoModel"], (ListView, ToDo) ->
    		contentHolder.empty()
    		list = new ListView();
    		list.$el.appendTo contentHolder
    			
    		describe "Base list view", ->
    			children = list.$el.find "ol li"
    			it "should add appropiate children rendering", ->
    				expect( children ).to.have.length.above 0
    			
    			it "Should remove all nested children as part of the cleanUp routine", ->
    				list.cleanUp()
    				expect( children ).to.have.length.lessThan 1
    */

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
    require(["view/Todo"], function(ToDoView) {
      var todos, view;
      todos = [
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
      view = new ToDoView();
      return describe("To Do list view", function() {
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
    require(["model/ScheduleModel", "model/SettingsModel", "momentjs"], function(ScheduleModel, SettingsModel, Moment) {
      return describe("Schedule model", function() {
        var model, settings;
        model = settings = null;
        beforeEach(function() {
          model = new ScheduleModel();
          return settings = new SettingsModel();
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
            return expect(model.getDynamicTime("This Evening", moment("2013-01-01 18:00"))).to.equal("Tomorrow Evening");
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
    return require(["view/list/TagEditorOverlay"], function(TagEditorOverlay) {
      return describe("Tag Editor overlay", function() {
        return describe("selecting shared tags", function() {
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
      });
    });
  });

}).call(this);
