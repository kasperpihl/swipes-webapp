(function() {
  define(["jquery", "underscore", "backbone", "model/ToDoModel"], function($, _, Backbone, ToDoModel) {
    return describe("Router", function() {
      before(function() {
        swipy.router.navigate("", true);
        return swipy.router.route("test/reset", "reset test", function() {});
      });
      beforeEach(function() {
        return swipy.router.navigate("test/reset", true);
      });
      after(function(done) {
        swipy.router.once("route:root", function() {
          return done();
        });
        swipy.router.navigate("test/reset", true);
        return swipy.router.navigate("", true);
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
      return it("The router should have a custom history lookup, so we can call swipy.router.back() and make sure not to go outside our current domain, unlike history.back in the browser");
    });
  });

}).call(this);
