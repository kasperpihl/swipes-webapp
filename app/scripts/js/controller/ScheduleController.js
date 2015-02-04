(function() {
  define(["underscore", "backbone", "js/model/ScheduleModel", "momentjs"], function(_, Backbone, ScheduleModel) {
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
          require(["js/view/scheduler/ScheduleOverlay"], function(ScheduleOverlayView) {
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
        var analyticsOptions, date, task, _i, _len, _ref;
        if (!this.currentTasks) {
          return;
        }
        if (option === "pick a date") {
          return Backbone.trigger("select-date");
        }
        if (typeof option === "string") {
          date = this.model.getDateFromScheduleOption(option);
        } else if (typeof option === "object") {
          date = option.toDate();
        }
        _ref = this.currentTasks;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          task = _ref[_i];
          task.scheduleTask(date);
        }
        analyticsOptions = this.getAnalyticsDataFromOption(option, date);
        swipy.analytics.sendEvent("Tasks", "Snoozed", analyticsOptions["Button Pressed"], analyticsOptions["Number of days ahead"]);
        swipy.analytics.sendEventToIntercom('Snoozed Tasks', analyticsOptions);
        this.view.currentTasks = void 0;
        return this.view.hide();
      };

      ScheduleController.prototype.getAnalyticsDataFromOption = function(option, date) {
        if (typeof option === "object") {
          option = "Calendar";
        } else {
          option = (function() {
            switch (option) {
              case "later today":
                return "Later Today";
              case "this evening":
                return "This Evening";
              case "tomorrow":
                return "Tomorrow";
              case "day after tomorrow":
                return "In 2 Days";
              case "this weekend":
                return "This Weekend";
              case "next week":
                return "Next Week";
              default:
                return "Unspecified";
            }
          })();
        }
        return {
          "Button Pressed": option,
          "Number of Tasks": this.currentTasks.length,
          "Number of days ahead": this.getDayDiff(date),
          "Used Time Picker": "No"
        };
      };

      ScheduleController.prototype.getDayDiff = function(date) {
        var diff;
        if (!date) {
          return "";
        }
        diff = moment(date).diff(new moment(), "days");
        if (diff < 7) {
          return diff;
        } else if (diff < 15) {
          return "7-14";
        } else if (diff < 29) {
          return "15-28";
        } else if (diff < 43) {
          return "29-42";
        } else if (diff < 57) {
          return "43-56";
        } else {
          return "56+";
        }
        return diff;
      };

      ScheduleController.prototype.selectDate = function() {
        return this.view.showDatePicker();
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
