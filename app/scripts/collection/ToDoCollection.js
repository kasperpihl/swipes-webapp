(function() {
  define(['backbone', 'backbone.localStorage', 'model/ToDoModel'], function(Backbone, BackboneLocalStorage, ToDoModel) {
    return Backbone.Collection.extend({
      model: ToDoModel,
      localStorage: new Backbone.LocalStorage("SwipyTodos"),
      initialize: function() {
        var _this = this;
        this.on("add", function(model) {
          return model.save();
        });
        return this.on("destroy", function(model) {
          return _this.remove(model);
        });
      },
      getActive: function() {
        var now,
          _this = this;
        now = new Date().getTime();
        return this.filter(function(m) {
          var schedule;
          schedule = m.getValidatedSchedule();
          if (!schedule || m.get("completionDate")) {
            return false;
          } else {
            return schedule.getTime() <= now;
          }
        });
      },
      getScheduled: function() {
        var now,
          _this = this;
        now = new Date().getTime();
        return this.filter(function(m) {
          var schedule;
          if (m.get("completionDate")) {
            return false;
          }
          schedule = m.getValidatedSchedule();
          if (schedule === null) {
            return true;
          }
          return schedule.getTime() > now;
        });
      },
      getCompleted: function() {
        var _this = this;
        return this.filter(function(m) {
          return m.get("completionDate") != null;
        });
      },
      bumpOrder: function(direction, startFrom) {
        var model, _i, _j, _len, _len1, _ref, _ref1, _results, _results1;
        if (direction == null) {
          direction = "down";
        }
        if (startFrom == null) {
          startFrom = 0;
        }
        if (direction === "down") {
          _ref = swipy.todos.getActive();
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            model = _ref[_i];
            if (!(model.has("order") && model.get("order") >= startFrom)) {
              continue;
            }
            console.log("Bumping " + (model.get('title')) + " from " + (model.get('order')) + " to ", model.get("order") + 1);
            _results.push(model.set("order", model.get("order") + 1));
          }
          return _results;
        } else if (direction === "up") {
          _ref1 = swipy.todos.getActive();
          _results1 = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            model = _ref1[_j];
            if (!(model.has("order") && model.get("order") > startFrom)) {
              continue;
            }
            console.log("Bumping " + (model.get('title')) + " from " + (model.get('order')) + " to ", model.get("order") - 1);
            _results1.push(model.set("order", model.get("order") - 1));
          }
          return _results1;
        }
      }
    });
  });

}).call(this);
