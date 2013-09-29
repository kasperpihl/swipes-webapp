(function() {
  define(["underscore", "backbone", "view/scheduler/ScheduleOverlay", "model/DateConverter"], function(_, Backbone, ScheduleOverlayView, DateConverter) {
    var ViewController;
    return ViewController = (function() {
      function ViewController(opts) {
        this.init();
      }

      ViewController.prototype.init = function() {
        this.view = new ScheduleOverlayView();
        this.dateConverter = new DateConverter();
        $("body").append(this.view.render().el);
        Backbone.on("schedule-task", this.showScheduleView, this);
        return Backbone.on("pick-schedule-option", this.pickOption, this);
      };

      ViewController.prototype.showScheduleView = function(tasks) {
        this.currentTasks = tasks;
        return this.view.show();
      };

      ViewController.prototype.pickOption = function(option) {
        var date, task, _i, _len, _ref;
        if (!this.currentTasks) {
          return;
        }
        date = this.dateConverter.getDateFromScheduleOption(option);
        _ref = this.currentTasks;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          task = _ref[_i];
          task.unset("schedule", {
            silent: true
          });
          task.set("schedule", date);
        }
        return this.view.hide();
      };

      ViewController.prototype.destroy = function() {
        this.view.remove();
        return Backbone.off(null, null, this);
      };

      return ViewController;

    })();
  });

}).call(this);
