(function() {
  require(["jquery", "underscore", "backbone", "model/ToDoModel"], function($, _, Backbone, ToDoModel) {
    var contentHolder, helpers;
    contentHolder = $("#content-holder");
    helpers = {
      getDummyModels: function() {
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

    require(["view/Schedule"], function(ScheduleView) {
      var laterToday, nextMonth, now, todos, tomorrow, view;
      laterToday = new Date();
      tomorrow = new Date();
      nextMonth = new Date();
      now = new Date();
      laterToday.setHours(now.getHours() + 1);
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
        return it("Should order tasks by models 'order' property", function() {
          var result;
          result = view.groupTasks(todos);
          expect(result[0].tasks[0].get("title")).to.equal("one");
          expect(result[0].tasks[1].get("title")).to.equal("two");
          return expect(result[0].tasks[2].get("title")).to.equal("three");
        });
      });
    });
    require(["view/Completed"], function(CompletedView) {
      var earlierToday, now, prevMonth, todos, view, yesterday;
      earlierToday = new Date();
      yesterday = new Date();
      prevMonth = new Date();
      now = new Date();
      earlierToday.setHours(now.getHours() - 1);
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
    return require(["model/ScheduleModel", "momentjs"], function(ScheduleModel, Moment) {
      return describe("Schedule model", function() {
        var model;
        model = null;
        beforeEach(function() {
          return model = new ScheduleModel();
        });
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
        it("Should return a new date 3 hours in the future when scheduling for 'later today'", function() {
          var newDate, now, parsedNewDate;
          now = moment();
          newDate = model.getDateFromScheduleOption("later today", now);
          parsedNewDate = moment(newDate);
          return expect(parsedNewDate.diff(now, "hours")).to.equal(3);
        });
        it("Should return a new date tomorrow at 09:00 when scheduling for 'tomorrow'", function() {
          return expect(2).to.be.lessThan(1);
        });
        it("Should return a new date 2 days from now at 09:00 when scheduling for 'day after tomorrow'", function() {
          return expect(2).to.be.lessThan(1);
        });
        it("Should return a new date this following saturday at 10:00 when scheduling for 'this weekend'", function() {
          return expect(2).to.be.lessThan(1);
        });
        it("Should return a new date this following monday at 9:00 when scheduling for 'next week'", function() {
          return expect(2).to.be.lessThan(1);
        });
        it("Should return null when scheduling for 'unspecified'", function() {
          return expect(2).to.be.lessThan(1);
        });
        return it("Should return a specific date when scheduling for 'pick a date'", function() {
          return expect(2).to.be.lessThan(1);
        });
      });
    });
  });

}).call(this);
