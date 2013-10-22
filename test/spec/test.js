(function() {
  define(["jquery", "underscore", "backbone", "model/ToDoModel"], function($, _, Backbone, ToDoModel) {
    return describe("Router", function() {
      before(function() {
        location.hash = "";
        return swipy.router.route("test/reset", "reset test", function() {});
      });
      beforeEach(function() {
        return location.hash = "test/reset";
      });
      after(function(done) {
        swipy.router.once("route:root", function() {
          return done();
        });
        location.hash = "test/reset";
        return location.hash = "";
      });
      it("Should make sure everything is reset before we start testing routes", function() {
        return expect(swipy.settings.view.shown).to.be.falsy;
      });
      it("Should trigger appropiate logic when navigating to 'settings'", function() {
        var eventTriggered,
          _this = this;
        eventTriggered = false;
        Backbone.once("show-settings", function() {
          return eventTriggered = true;
        });
        location.hash = "settings";
        return _.defer(function() {
          expect(eventTriggered).to.be["true"];
          return expect(swipy.settings.view).to.have.property("shown", true);
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
        return require(["view/editor/EditTask"], function(TaskEditor) {
          return setTimeout(function() {
            expect(swipy.viewController.currView).to.exist;
            expect(swipy.viewController.currView).to.be.instanceOf(TaskEditor);
            return done();
          }, 150);
        });
      });
      it("Should go back to list view when calling save on task editor", function(done) {
        var editTaskRoute;
        location.hash = "list/todo";
        editTaskRoute = "edit/" + (swipy.todos.at(0).cid);
        location.hash = editTaskRoute;
        return require(["view/editor/EditTask", "view/Todo"], function(TaskEditor, TodoList) {
          var editor;
          editor = swipy.viewController.currView;
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
        });
      });
      it("Should have a catch-all which forwards to 'list/todo'", function() {
        var eventTriggered, wentByRoot,
          _this = this;
        wentByRoot = false;
        eventTriggered = false;
        Backbone.once("navigate/view", function(id) {
          if (id === "todo") {
            return eventTriggered = true;
          }
        });
        swipy.router.once("route:root", function() {
          return wentByRoot = true;
        });
        location.hash = "random/jibberish";
        return _.defer(function() {
          expect(wentByRoot).to.be["true"];
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
        testRoutes = ["list/todo", "list/scheduled", "edit/" + (swipy.todos.at(0).cid), "list/completed", "list/todo", "settings", "list/scheduled"];
        console.group("Building router history");
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
          expect(routerTriggeredTimes).to.equal(testRoutes.length);
          expect(swipy.router.history).to.have.length(testRoutes.length);
          console.groupEnd();
          console.log("location hash is " + location.hash);
          expect(location.hash).to.equal("#" + testRoutes[testRoutes.length - 1]);
          swipy.router.back();
          console.log("location hash is " + location.hash);
          expect(location.hash).to.equal("#" + testRoutes[testRoutes.length - 2]);
          swipy.router.back();
          console.log("location hash is " + location.hash);
          expect(Backbone.history.fragment).to.equal("#" + testRoutes[testRoutes.length - 3]);
          return done();
        });
      });
    });
  });

}).call(this);
