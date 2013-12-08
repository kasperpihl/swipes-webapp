(function() {
  define(["model/ToDoModel"], function(ToDoModel) {
    return Parse.Collection.extend({
      model: ToDoModel,
      initialize: function() {
        var _this = this;
        this.setQuery();
        this.on("change:deleted", function(model, deleted) {
          if (deleted) {
            return _this.remove(model);
          } else {
            return _this.add(model);
          }
        });
        this.on("change:title", function(model, newTitle) {
          return console.log("Changed title to " + newTitle);
        });
        return this.on("reset", function() {
          var m, removeThese, _i, _j, _len, _len1, _ref;
          removeThese = [];
          _ref = this.models;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            m = _ref[_i];
            if (m.get("deleted")) {
              removeThese.push(m);
            }
          }
          for (_j = 0, _len1 = removeThese.length; _j < _len1; _j++) {
            m = removeThese[_j];
            this.remove(m);
          }
          return this.invoke("set", {
            rejectedByTag: false,
            rejectedBySearch: false
          });
        });
      },
      setQuery: function() {
        this.query = new Parse.Query(ToDoModel);
        this.query.equalTo("owner", Parse.User.current());
        this.query.notEqualTo("deleted", true);
        return this.query.limit(1000);
      },
      getActive: function() {
        return this.filter(function(m) {
          return m.getState() === "active";
        });
      },
      getScheduled: function() {
        return this.filter(function(m) {
          return m.getState() === "scheduled";
        });
      },
      getCompleted: function() {
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
            return _.contains(m.getTagStrList(), tag);
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
      }
    });
  });

}).call(this);
