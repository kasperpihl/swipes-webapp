(function() {
  define(["underscore", "backbone"], function(_, Backbone) {
    return Backbone.View.extend({
      el: "#add-task",
      events: {
        "submit": "triggerAddTask"
      },
      initialize: function() {
        return this.input = this.$el.find("input");
      },
      triggerAddTask: function(e) {
        e.preventDefault();
        if (this.input.val() === "") {
          return;
        }
        Backbone.trigger("create-task", this.input.val());
        return this.input.val("");
      },
      remove: function() {
        this.undelegateEvents();
        return this.$el.remove();
      }
    });
  });

}).call(this);
