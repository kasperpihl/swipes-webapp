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
        this.on("destroy", function(model) {
          return _this.remove(model);
        });
        return this.on("change:completionDate", this.spawnRepeatTask);
      },
      getActive: function() {
        var _this = this;
        return this.filter(function(m) {
          return m.getState() === "active";
        });
      },
      getScheduled: function() {
        var _this = this;
        return this.filter(function(m) {
          return m.getState() === "scheduled";
        });
      },
      getCompleted: function() {
        var _this = this;
        return this.filter(function(m) {
          return m.getState() === "completed";
        });
      },
      getActiveList: function() {
        var route;
        route = swipy.router.getCurrRoute();
        switch (route) {
          case "":
          case "list/todo":
          case "list/scheduled":
          case "list/completed":
            if (route === "" || route === "list/todo") {
              return "todo";
            } else {
              return route.replace("list/", "");
            }
            break;
          default:
            return "todo";
        }
      },
      getTasksTaggedWith: function(tags, filterOnlyCurrentTasks) {
        var activeList, models;
        activeList = this.getActiveList();
        switch (activeList) {
          case "todo":
            models = this.getActive();
            break;
          case "scheduled":
            models = this.getScheduled();
            break;
          default:
            models = this.getCompleted();
        }
        return _.filter(models, function(m) {
          if (!m.has("tags")) {
            return false;
          }
          if (typeof tags !== "object") {
            tags = [tags];
          }
          return _.all(tags, function(tag) {
            return _.contains(m.get("tags"), tag);
          });
        });
      },
      bumpOrder: function(direction, startFrom, bumps) {
        var model, _i, _j, _len, _len1, _ref, _ref1, _results, _results1;
        if (direction == null) {
          direction = "down";
        }
        if (startFrom == null) {
          startFrom = 0;
        }
        if (bumps == null) {
          bumps = 1;
        }
        if (direction === "down") {
          _ref = swipy.todos.getActive();
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            model = _ref[_i];
            if (model.has("order") && model.get("order") >= startFrom) {
              _results.push(model.set("order", model.get("order") + bumps));
            }
          }
          return _results;
        } else if (direction === "up") {
          _ref1 = swipy.todos.getActive();
          _results1 = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            model = _ref1[_j];
            if (model.has("order") && model.get("order") > startFrom) {
              _results1.push(model.set("order", model.get("order") - bumps));
            }
          }
          return _results1;
        }
      },
      spawnRepeatTask: function(model, completionDate) {
        if (model.get("repeatDate")) {
          return this.add(model.getRepeatableDuplicate().attributes);
        }
      }
    });
  });

}).call(this);
