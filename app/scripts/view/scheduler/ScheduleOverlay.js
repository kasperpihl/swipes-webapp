(function() {
  define(["underscore", "backbone", "view/Overlay"], function(_, Backbone, Overlay) {
    return Overlay.extend({
      bindEvents: function() {
        return this.listenTo(Backbone, "schedule-task", this.schedule);
      },
      init: function() {
        return console.log("New Schedule Overlay created");
      },
      schedule: function(tasks) {
        console.log("Schedule tasks: ", tasks);
        return this.show();
      },
      afterShow: function() {}
    });
  });

}).call(this);
