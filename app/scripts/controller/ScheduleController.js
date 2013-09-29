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
        Backbone.on("schedule-task", this.showScheduleView, this);
        return Backbone.on("pick-schedule-option", this.pickOption, this);
      };

      ViewController.prototype.showScheduleView = function(tasks) {
        this.currentTasks = tasks;
        return this.view.show();
      };

      ViewController.prototype.pickOption = function(option) {
        if (!this.currentTasks) {
          return;
        }
        return console.log("Schdule ", this.currentTasks, " for " + option + ".");
      };

      ViewController.prototype.destroy = function() {
        this.view.remove();
        return Backbone.off(null, null, this);
      };

      return ViewController;

    })();
  });

}).call(this);
