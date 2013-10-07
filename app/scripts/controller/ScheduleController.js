(function() {
  define(["underscore", "backbone", "view/scheduler/ScheduleOverlay", "model/ScheduleModel"], function(_, Backbone, ScheduleOverlayView, ScheduleModel) {
    var ScheduleController;
    return ScheduleController = (function() {
      function ScheduleController(opts) {
        this.init();
      }

      ScheduleController.prototype.init = function() {
        this.model = new ScheduleModel();
        this.view = new ScheduleOverlayView({
          model: this.model
        });
        $("body").append(this.view.render().el);
        Backbone.on("show-scheduler", this.showScheduleView, this);
        Backbone.on("pick-schedule-option", this.pickOption, this);
        return Backbone.on("select-date", this.selectDate, this);
      };

      ScheduleController.prototype.showScheduleView = function(tasks) {
        this.view.currentTasks = this.currentTasks = tasks;
        return this.view.show();
      };

      ScheduleController.prototype.pickOption = function(option) {
        var date, task, _i, _len, _ref;
        if (!this.currentTasks) {
          return;
        }
        if (option === "pick a date") {
          return Backbone.trigger("select-date");
        }
        date = this.model.getDateFromScheduleOption(option);
        _ref = this.currentTasks;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          task = _ref[_i];
          task.unset("schedule", {
            silent: true
          });
          task.set("schedule", date);
        }
        this.view.currentTasks = void 0;
        return this.view.hide();
      };

      ScheduleController.prototype.selectDate = function() {
        return console.log("Select a date");
      };

      ScheduleController.prototype.destroy = function() {
        this.view.remove();
        return Backbone.off(null, null, this);
      };

      return ScheduleController;

    })();
  });

}).call(this);
