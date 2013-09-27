(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      el: ".action-bar",
      events: {
        "click .edit": "editTask"
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
      editTask: function(e) {
        return console.log("Edit task: ", arguments);
      }
    });
  });

}).call(this);
