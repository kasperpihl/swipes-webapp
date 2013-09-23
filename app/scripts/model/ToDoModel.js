(function() {
  define(["backbone", "momentjs"], function(Backbone, Moment) {
    return Backbone.Model.extend({
      defaults: {
        title: "",
        order: void 0,
        schedule: null,
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
        if (this.get("schedule") === null) {
          this.set("schedule", this.getDefaultSchedule());
        }
        if (typeof this.get("schedule") === "string") {
          this.set("schedule", new Date(this.get("schedule")));
        }
        this.setScheduleStr();
        this.setTimeStr();
        this.on("change:schedule", function() {
          _this.setScheduleStr();
          return _this.setTimeStr();
        });
        this.on("change:completionDate", function() {
          _this.setCompletionStr();
          return _this.setCompletionTimeStr();
        });
        if (this.has("completionDate")) {
          this.setCompletionStr();
          return this.setCompletionTimeStr();
        }
      },
      getDefaultSchedule: function() {
        var now;
        now = new Date();
        now.setSeconds(now.getSeconds() - 1);
        return now;
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
      getDayWithoutTime: function(moment) {
        return moment.calendar().match(/\w+/)[0];
      },
      setScheduleStr: function() {
        var dayDiff, dayWithoutTime, now, parsedDate, result, schedule;
        schedule = this.get("schedule");
        if (!schedule) {
          if (this.get("completionDate")) {
            this.set("scheduleStr", "the past");
            return this.get("scheduleStr");
          } else {
            return false;
          }
        }
        now = moment();
        parsedDate = moment(schedule);
        if (parsedDate.isBefore()) {
          return this.set("scheduleStr", "the past");
        }
        dayDiff = parsedDate.diff(now, "days");
        if (dayDiff > 7) {
          if (parsedDate.year() > now.year()) {
            result = parsedDate.format("MMM Do 'YY");
          } else {
            result = parsedDate.format("MMM Do");
          }
          return this.set("scheduleStr", result);
        }
        dayWithoutTime = this.getDayWithoutTime(parsedDate);
        if (dayWithoutTime === "Today") {
          dayWithoutTime = "Later today";
        }
        return this.set("scheduleStr", dayWithoutTime);
      },
      setTimeStr: function() {
        var schedule;
        schedule = this.get("schedule");
        if (!schedule) {
          return this.set("timeStr", void 0);
        }
        return this.set("timeStr", moment(schedule).format("h:mmA"));
      },
      setCompletionStr: function() {
        var completionDate, dayDiff, dayWithoutTime, now, parsedDate, result;
        completionDate = this.get("completionDate");
        if (!completionDate) {
          return this.set("completionStr", void 0);
        }
        now = moment();
        parsedDate = moment(completionDate);
        dayDiff = parsedDate.diff(now, "days");
        if (dayDiff < -7) {
          if (parsedDate.year() < now.year()) {
            result = parsedDate.format("MMM Do 'YY");
          } else {
            result = parsedDate.format("MMM Do");
          }
          return this.set("completionStr", result);
        }
        dayWithoutTime = this.getDayWithoutTime(parsedDate);
        if (dayWithoutTime === "Today") {
          dayWithoutTime = "Earlier today";
        }
        return this.set("completionStr", dayWithoutTime);
      },
      setCompletionTimeStr: function() {
        var completionDate;
        completionDate = this.get("completionDate");
        if (!completionDate) {
          return this.set("completionTimeStr", void 0);
        }
        return this.set("completionTimeStr", moment(completionDate).format("h:mmA"));
      }
    });
  });

}).call(this);
