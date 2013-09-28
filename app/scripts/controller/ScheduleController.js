(function() {
  define(["underscore", "backbone", "view/scheduler/ScheduleOverlay"], function(_, Backbone, ScheduleOverlayView) {
    var ViewController;
    return ViewController = (function() {
      function ViewController(opts) {
        this.init();
      }

      ViewController.prototype.init = function() {
        this.view = new ScheduleOverlayView();
        $("body").append(this.view.render().el);
        return Backbone.on("schedule-task", this.scheduleTasks, this);
      };

      ViewController.prototype.scheduleTasks = function(tasks) {
        console.log("Schedule tasks: ", tasks);
        return this.view.show();
      };

      ViewController.prototype.destroy = function() {
        this.view.remove();
        return Backbone.off(null, null, this);
      };

      return ViewController;

    })();
  });

}).call(this);
