(function() {
  define(["underscore", "backbone", "model/ScheduleModel"], function(_, Backbone, ScheduleModel) {
    var ScheduleController;
    return ScheduleController = (function() {
      function ScheduleController(opts) {
        this.init();
      }

      ScheduleController.prototype.init = function() {
        this.model = new ScheduleModel();
        Backbone.on("show-scheduler", this.showScheduleView, this);
        Backbone.on("pick-schedule-option", this.pickOption, this);
        return Backbone.on("select-date", this.selectDate, this);
      };

      ScheduleController.prototype.showScheduleView = function(tasks) {
        var loadViewDfd,
          _this = this;
        loadViewDfd = new $.Deferred();
        if (this.view == null) {
          require(["view/scheduler/ScheduleOverlay"], function(ScheduleOverlayView) {
            _this.view = new ScheduleOverlayView({
              model: _this.model
            });
            $("body").append(_this.view.render().el);
            return loadViewDfd.resolve();
          });
        } else {
          loadViewDfd.resolve();
        }
        return loadViewDfd.promise().done(function() {
          _this.view.show();
          return _this.view.currentTasks = _this.currentTasks = tasks;
        });
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
          task.set({
            schedule: date,
            completionDate: null
          });
        }
        this.view.currentTasks = void 0;
        return this.view.hide();
      };

      ScheduleController.prototype.selectDate = function() {
        return console.log("Select a date");
      };

      ScheduleController.prototype.destroy = function() {
        var _ref;
        if ((_ref = this.view) != null) {
          _ref.remove();
        }
        return Backbone.off(null, null, this);
      };

      return ScheduleController;

    })();
  });

}).call(this);
