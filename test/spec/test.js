(function() {
  define(["jquery", "underscore", "backbone", "model/ToDoModel"], function($, _, Backbone, ToDoModel) {
    return describe("Router", function() {
      before(function() {
        swipy.router.navigate("", true);
        return swipy.router.route("test/reset", "reset test", function() {
          return console.log("Reset router for test");
        });
      });
      beforeEach(function() {
        return swipy.router.navigate("test/reset", true);
      });
      after(function(done) {
        swipy.router.once("route:root", function() {
          return done();
        });
        return swipy.router.navigate("", true);
      });
      it("Should make sure everything is reset before we start testing routes", function() {});
      it("Should trigger appropiate logic when navigating to 'settings'", function() {
        var eventTriggered,
          _this = this;
        eventTriggered = false;
        Backbone.once("show-settings", function() {
          return eventTriggered = true;
        });
        location.hash = "settings";
        return _.defer(function() {
          return expect(eventTriggered).to.be["true"];
        });
      });
      it("Should should not open any settings sub view when just navigating to 'settings'", function() {
        return location.hash = "settings";
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
          return expect(eventTriggered).to.be["true"];
        });
        return setTimeout(function() {
          return done();
        }, 150);
      });
      it("Should trigger appropiate logic when navigating to 'list/:id'", function(done) {
        var eventTriggered,
          _this = this;
        eventTriggered = false;
        Backbone.once("navigate/view", function(id) {
          if (id === "schedule") {
            return eventTriggered = true;
          }
        });
        location.hash = "list/schedule";
        _.defer(function() {
          return expect(eventTriggered).to.be["true"];
        });
        return setTimeout(function() {
          return done();
        }, 150);
      });
      return it("Should have a catch-all which forwards to 'list/todo'");
    });
  });

}).call(this);
