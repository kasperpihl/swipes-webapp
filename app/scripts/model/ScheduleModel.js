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
        var newDate, snoozes;
        if (now) {
          newDate = moment(now);
        } else {
          newDate = moment();
        }
        snoozes = swipy.settings.get("snoozes");
        switch (option) {
          case "later today":
            newDate.hour(newDate.hour() + snoozes.laterTodayDelay.hours);
            newDate.minute(newDate.minute() + snoozes.laterTodayDelay.minutes);
            break;
          case "this evening":
            if (newDate.hour() >= snoozes.weekday.evening.hour) {
              newDate.add("days", 1);
            }
            newDate.hour(snoozes.weekday.evening.hour);
            newDate.minute(snoozes.weekday.evening.minute);
            newDate = newDate.startOf("minute");
            break;
          case "tomorrow":
            newDate.add("days", 1);
            newDate.hour(snoozes.weekday.morning.hour);
            newDate.minute(snoozes.weekday.morning.minute);
            newDate = newDate.startOf("minute");
            break;
          case "day after tomorrow":
            newDate.add("days", 2);
            newDate.hour(snoozes.weekday.morning.hour);
            newDate.minute(snoozes.weekday.morning.minute);
            newDate = newDate.startOf("minute");
            break;
          case "this weekend":
            if (newDate.day() === snoozes.weekend.startDay.number) {
              newDate.add("days", 7);
            } else {
              newDate.day(snoozes.weekend.startDay.name);
            }
            newDate.hour(snoozes.weekend.morning.hour);
            newDate.minute(snoozes.weekend.morning.minute);
            newDate = newDate.startOf("minute");
            break;
          case "next week":
            if (newDate.day() === snoozes.weekday.startDay.number) {
              newDate.add("days", 7);
            } else {
              newDate.day(snoozes.weekday.start);
            }
            newDate.hour(snoozes.weekday.morning.hour);
            newDate.minute(snoozes.weekday.morning.minute);
            newDate = newDate.startOf("minute");
            break;
          default:
            return null;
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
              return "Tomorrow Eve";
            } else {
              return "This Evening";
            }
          case "Day After Tomorrow":
            dayAfterTomorrow = moment(now).add("days", 2);
            return dayAfterTomorrow.format("dddd");
          case "This Weekend":
            if (now.day() < 5) {
              return "This Weekend";
            } else {
              return "Next Weekend";
            }
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
