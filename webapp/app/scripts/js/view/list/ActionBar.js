(function() {
  define(["underscore", "backbone", "js/view/list/TagEditorOverlay"], function(_, Backbone, TagEditorOverlay) {
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
        this.undelegateEvents();
        this.stopListening();
        return this.hide();
      },
      editTask: function() {
        var target;
        target = swipy.todos.filter(function(m) {
          return m.get("selected");
        })[0].id;
        return swipy.router.navigate("edit/" + target, true);
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
        if (!selectedTasks.length) {
          return;
        }
        if (confirm("Delete " + selectedTasks.length + " tasks?")) {
          for (_i = 0, _len = selectedTasks.length; _i < _len; _i++) {
            model = selectedTasks[_i];
            if (model.has("order")) {
              order = model.get("order");
              model.unset("order");
              swipy.todos.bumpOrder("up", order);
            }
            model.deleteObj();
          }
          this.hide();
          return swipy.analytics.sendEvent("Tasks", "Deleted", "", selectedTasks.length);
        }
      },
      shareTasks: function() {
        var emailString, selectedTasks, task, _i, _len;
        selectedTasks = swipy.todos.filter(function(m) {
          return m.get("selected");
        });
        if (!selectedTasks.length) {
          return;
        }
        emailString = "				mailto:				?subject=Tasks to complete				&body=			";
        emailString += encodeURIComponent("Tasks: \r\n");
        for (_i = 0, _len = selectedTasks.length; _i < _len; _i++) {
          task = selectedTasks[_i];
          emailString += encodeURIComponent("◯ " + task.get("title") + "\r\n");
        }
        emailString += encodeURIComponent("\r\nSent from Swipes — http://swipesapp.com");
        location.href = emailString;
        return swipy.analytics.sendEvent("Share Task", "Opened", "", selectedTasks.length);
      }
    });
  });

}).call(this);
