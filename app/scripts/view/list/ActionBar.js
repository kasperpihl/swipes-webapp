(function() {
  define(["underscore", "backbone", "view/list/TagEditorOverlay"], function(_, Backbone, TagEditorOverlay) {
    return Backbone.View.extend({
      el: ".action-bar",
      events: {
        "click .edit": "editTask",
        "click .tags": "editTags",
        "click .delete": "deleteTasks",
        "click .share": "shareTasks"
      },
      initialize: function() {
        this.hide();
        return this.listenTo(swipy.todos, "change:selected", this.toggle);
      },
      toggle: function() {
        var selectedTasks;
        selectedTasks = swipy.todos.filter(function(m) {
          return m.get("selected");
        });
        if (this.shown) {
          if (selectedTasks.length === 0) {
            return this.hide();
          }
        } else {
          if (selectedTasks.length > 0) {
            return this.show();
          }
        }
      },
      show: function() {
        this.$el.toggleClass("fadeout", false);
        return this.shown = true;
      },
      hide: function() {
        this.$el.toggleClass("fadeout", true);
        return this.shown = false;
      },
      kill: function() {
        this.stopListening();
        return this.hide();
      },
      editTask: function() {
        var targetCid;
        targetCid = swipy.todos.filter(function(m) {
          return m.get("selected");
        })[0].cid;
        return swipy.router.navigate("edit/" + targetCid, true);
      },
      editTags: function() {
        return this.tagEditor = new TagEditorOverlay({
          models: swipy.todos.filter(function(m) {
            return m.get("selected");
          })
        });
      },
      deleteTasks: function() {
        var model, order, selectedTasks, _i, _len;
        selectedTasks = swipy.todos.filter(function(m) {
          return m.get("selected");
        });
        if (confirm("Delete " + selectedTasks.length + " tasks?")) {
          for (_i = 0, _len = selectedTasks.length; _i < _len; _i++) {
            model = selectedTasks[_i];
            if (model.has("order")) {
              order = model.get("order");
              model.unset("order");
              swipy.todos.bumpOrder("up", order);
            }
            model.destroy();
          }
          return this.hide();
        }
      },
      shareTasks: function() {
        return alert("Task sharing is coming soon :)");
      }
    });
  });

}).call(this);
