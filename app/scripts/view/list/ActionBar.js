(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      el: ".action-bar",
      events: {
        "click .edit": "editTask",
        "click .delete": "deleteTasks"
      },
      initialize: function() {
        this.shown = false;
        return this.listenTo(swipy.todos, "change:selected", this.toggle);
      },
      toggle: function() {
        if (this.shown) {
          if (swipy.todos.filter(function(m) {
            return m.get("selected");
          }).length === 0) {
            return this.hide();
          }
        } else {
          if (swipy.todos.filter(function(m) {
            return m.get("selected");
          }).length === 1) {
            return this.show();
          }
        }
      },
      show: function() {
        this.$el.removeClass("fadeout");
        return this.shown = true;
      },
      hide: function() {
        this.$el.addClass("fadeout");
        return this.shown = false;
      },
      kill: function() {
        this.stopListening();
        return this.hide();
      },
      editTask: function() {
        var targetCid;
        targetCid = swipy.todos.findWhere({
          selected: true
        }).cid;
        return swipy.router.navigate("edit/" + targetCid, true);
      },
      deleteTasks: function() {
        var model, targets, _i, _len, _results;
        targets = swipy.todos.where({
          selected: true
        });
        if (confirm("Delete " + targets.length + " tasks?")) {
          _results = [];
          for (_i = 0, _len = targets.length; _i < _len; _i++) {
            model = targets[_i];
            _results.push(model.destroy());
          }
          return _results;
        }
      }
    });
  });

}).call(this);
