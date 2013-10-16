(function() {
  define(["view/list/BaseTask"], function(BaseTaskView) {
    return BaseTaskView.extend({
      bindEvents: function() {
        return this.$el.on("tap", ".todo-content", this.toggleSelected);
      },
      enableReordering: function() {
        return console.warn("Enabling touch gestures for reordering");
      },
      disableReordering: function() {
        return console.warn("Disabling touch gestures for reordering");
      }
    });
  });

}).call(this);
