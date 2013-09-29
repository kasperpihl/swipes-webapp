(function() {
  define(["underscore", "momentjs"], function(_, Moment) {
    var ScheduleModel;
    return ScheduleModel = (function() {
      function ScheduleModel(settings) {
        this.settings = settings;
        this.validateSettings();
        this.data = this.getData();
      }

      ScheduleModel.prototype.validateSettings = function() {};

      ScheduleModel.prototype.getData = function() {
        return [
          {
            id: "later today",
            title: this.getDynamicTime("Later Today"),
            disabled: false
          }, {
            id: "this evening",
            title: this.getDynamicTime("This Evening"),
            disabled: false
          }, {
            id: "tomorrow",
            title: this.getDynamicTime("Tomorrow"),
            disabled: false
          }, {
            id: "day after tomorrow",
            title: this.getDynamicTime("Day After Tomorrow"),
            disabled: false
          }, {
            id: "this weekend",
            title: this.getDynamicTime("This Weekend"),
            disabled: false
          }, {
            id: "next week",
            title: this.getDynamicTime("Next Week"),
            disabled: false
          }, {
            id: "unspecified",
            title: this.getDynamicTime("Unspecified"),
            disabled: false
          }, {
            id: "at location",
            title: this.getDynamicTime("At Location"),
            disabled: true
          }, {
            id: "pick a date",
            title: this.getDynamicTime("Pick A Date"),
            disabled: false
          }
        ];
      };

      ScheduleModel.prototype.getDateFromScheduleOption = function(option, now) {
        var newDate, times;
        if (now) {
          newDate = moment(now);
        } else {
          newDate = moment();
        }
        times = {
          laterTodayDelay: 3,
          morning: 9,
          evening: 18
        };
        switch (option) {
          case "later today":
            newDate.hour(newDate.hour() + times.laterTodayDelay);
            break;
          case "this evening":
            newDate.hour(times.evening);
            if (now.hour() > times.evening) {
              newDate.dayOfYear(newDate.dayOfYear() + 1);
            }
            break;
          case "tomorrow":
            newDate.dayOfYear(newDate.dayOfYear() + 1);
            newDate.hour(times.morning);
            break;
          case "day after tomorrow":
            newDate.dayOfYear(newDate.dayOfYear() + 2);
            newDate.hour(times.morning);
        }
        return newDate.toDate();
      };

      ScheduleModel.prototype.getDynamicTime = function(time, now) {
        var dayAfterTomorrow;
        if (!now) {
          now = moment();
        }
        switch (time) {
          case "This Evening":
            if (now.hour() >= 18) {
              return "Tomorrow Evening";
            } else {
              return "This Evening";
            }
          case "Day After Tomorrow":
            dayAfterTomorrow = moment(now);
            dayAfterTomorrow.day(dayAfterTomorrow.day() + 2);
            return dayAfterTomorrow.format("dddd");
          default:
            return time;
        }
      };

      ScheduleModel.prototype.toJSON = function() {
        return {
          options: this.data
        };
      };

      return ScheduleModel;

    })();
  });

}).call(this);
