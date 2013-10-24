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
        if (this.shown) {
          if (swipy.todos.where({
            selected: true
          }).length === 0) {
            return this.hide();
          }
        } else {
          if (swipy.todos.where({
            selected: true
          }).length > 0) {
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
        targetCid = swipy.todos.findWhere({
          selected: true
        }).cid;
        return swipy.router.navigate("edit/" + targetCid, true);
      },
      editTags: function() {
        return this.tagEditor = new TagEditorOverlay({
          models: swipy.todos.where({
            selected: true
          })
        });
      },
      deleteTasks: function() {
        var model, order, targets, _i, _len;
        targets = swipy.todos.where({
          selected: true
        });
        if (confirm("Delete " + targets.length + " tasks?")) {
          for (_i = 0, _len = targets.length; _i < _len; _i++) {
            model = targets[_i];
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
