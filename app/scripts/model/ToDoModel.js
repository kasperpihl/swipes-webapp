(function() {
  define(["backbone", "momentjs"], function(Backbone, Moment) {
    return Backbone.Model.extend({
      defaults: {
        title: "",
        order: 0,
        schedule: new Date(),
        completionDate: null,
        repeatOption: "never",
        repeatDate: null,
        repeatCount: 0,
        tags: null,
        notes: "",
        deleted: false
      },
      initialize: function() {
        var _this = this;
        this.setScheduleStr();
        this.setTimeStr();
        return this.on("change:schedule", function() {
          _this.setScheduleStr();
          return _this.setTimeStr();
        });
      },
      getValidatedSchedule: function() {
        var schedule;
        schedule = this.get("schedule");
        if (!schedule) {
          return false;
        }
        if (typeof schedule === "string") {
          this.set("schedule", new Date(schedule));
        }
        return this.get("schedule");
      },
      setScheduleStr: function() {
        var calendarWithoutTime, dayDiff, now, parsedDate, result, schedule;
        schedule = this.get("schedule");
        if (!schedule) {
          return this.unset("scheduleString");
        }
        now = moment();
        parsedDate = moment(schedule);
        if (parsedDate.isBefore()) {
          return this.set("scheduleString", "the past");
        }
        dayDiff = parsedDate.diff(now, "days");
        if (dayDiff > 7) {
          if (parsedDate.year() > now.year()) {
            result = parsedDate.format("MMM Do 'YY");
          } else {
            result = parsedDate.format("MMM Do");
          }
          return this.set("scheduleString", result);
        }
        calendarWithoutTime = parsedDate.calendar().match(/\w+/)[0];
        if (calendarWithoutTime === "Today") {
          calendarWithoutTime = "Later today";
        }
        return this.set("scheduleString", calendarWithoutTime);
      },
      setTimeStr: function() {
        var schedule;
        schedule = this.get("schedule");
        if (!schedule) {
          return this.set("timeStr", void 0);
        }
        return this.set("timeStr", moment(schedule).format("h:mmA"));
      }
    });
  });

}).call(this);
