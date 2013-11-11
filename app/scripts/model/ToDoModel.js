(function() {
  define(["backbone", "momentjs"], function(Backbone, Moment) {
    return Backbone.Model.extend({
      defaults: {
        title: "",
        order: void 0,
        schedule: "default",
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
        if (this.get("schedule") === "default") {
          this.set("schedule", this.getDefaultSchedule());
        }
        this.reviveDate("schedule");
        this.reviveDate("completionDate");
        this.reviveDate("repeatDate");
        if (this.get("repeatOption") !== "never") {
          this.updateRepeatDate();
        }
        this.setScheduleStr();
        this.setTimeStr();
        this.syncTags();
        this.on("change:schedule", function() {
          _this.setScheduleStr();
          _this.setTimeStr();
          return _this.set("selected", false);
        });
        this.on("change:completionDate", function() {
          _this.updateRepeatDate();
          _this.setCompletionStr();
          _this.setCompletionTimeStr();
          return _this.set("selected", false);
        });
        this.on("change:schedule", function() {
          return _this.reviveDate("schedule");
        });
        this.on("change:completionDate", function() {
          return _this.reviveDate("completionDate");
        });
        this.on("change:repeatDate", function() {
          return _this.reviveDate("repeatDate");
        });
        this.on("change:repeatOption", this.setRepeatOption);
        this.on("destroy", this.cleanUp);
        if (this.has("completionDate")) {
          this.setCompletionStr();
          this.setCompletionTimeStr();
        }
        return this.on("change:order", function() {
          if ((_this.get("order") != null) && _this.get("order") < 0) {
            return console.error("Model order value set to less than 0");
          }
        });
      },
      reviveDate: function(prop) {
        if (typeof this.get(prop) === "string") {
          return this.set(prop, new Date(this.get(prop)), {
            silent: true
          });
        }
      },
      getState: function() {
        var schedule;
        schedule = this.getValidatedSchedule();
        if (this.get("completionDate")) {
          return "completed";
        } else {
          if (schedule && schedule.getTime() <= new Date().getTime()) {
            return "active";
          } else {
            return "scheduled";
          }
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
        if (typeof schedule === "string") {
          this.set("schedule", new Date(schedule));
        }
        return this.get("schedule");
      },
      getDayWithoutTime: function(moment) {
        return moment.calendar().match(/\w+/)[0];
      },
      syncTags: function() {
        var tagName, _i, _len, _ref, _results;
        if (this.has("tags") && (typeof swipy !== "undefined" && swipy !== null ? swipy.tags : void 0)) {
          _ref = this.get("tags");
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            tagName = _ref[_i];
            _results.push(swipy.tags.add({
              title: tagName
            }));
          }
          return _results;
        }
      },
      setScheduleStr: function() {
        var dayWithoutTime, now, parsedDate, result, schedule;
        schedule = this.get("schedule");
        if (!schedule) {
          return this.set("scheduleStr", "unspecified");
        }
        now = moment();
        parsedDate = moment(schedule);
        if (Math.abs(parsedDate.diff(now, "days")) >= 7) {
          if (parsedDate.year() > now.year()) {
            result = parsedDate.format("MMM Do 'YY");
          } else {
            result = parsedDate.format("MMM Do");
          }
          return this.set("scheduleStr", result);
        }
        dayWithoutTime = this.getDayWithoutTime(parsedDate);
        if (dayWithoutTime === "Today" && !parsedDate.isBefore()) {
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
        var completionDate, dayWithoutTime, now, parsedDate, result;
        completionDate = this.get("completionDate");
        if (!completionDate) {
          return this.unset("completionStr");
        }
        now = moment();
        parsedDate = moment(completionDate);
        if (parsedDate.diff(now, "days") <= -7) {
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
          return this.unset("completionTimeStr");
        }
        return this.set("completionTimeStr", moment(completionDate).format("h:mmA"));
      },
      setRepeatOption: function(model, option) {
        if (this.get("schedule") && option !== "never") {
          return this.set("repeatDate", this.getNextDate(option));
        } else {
          return this.set("repeatDate", null);
        }
      },
      updateRepeatDate: function() {
        var option;
        option = this.get("repeatOption");
        if (this.get("schedule") && option !== "never") {
          return this.set("repeatDate", this.getNextDate(option));
        } else {
          return this.set("repeatDate", null);
        }
      },
      isWeekend: function(schedule) {
        if (schedule.getDay() === 0 || schedule.getDay() === 6) {
          return true;
        } else {
          return false;
        }
      },
      isWeekday: function(schedule) {
        return !this.isWeekend(schedule);
      },
      getMonFriSatSunFromDate: function(schedule, completionDate) {
        if (this.isWeekday(schedule)) {
          return this.getNextWeekDay(completionDate);
        } else {
          return this.getNextWeekendDay(completionDate);
        }
      },
      getNextWeekDay: function(date) {
        return date.add("days", date.day() === 5 ? 3 : 1).toDate();
      },
      getNextWeekendDay: function(date) {
        return date.add("days", date.day() === 0 ? 6 : 1).toDate();
      },
      getNextDate: function(option) {
        var completionDate, date, diff, repeatDate, type;
        if (this.has("completionDate")) {
          repeatDate = this.get("repeatDate");
          completionDate = this.get("completionDate");
          if (repeatDate) {
            if (repeatDate.getTime() > completionDate.getTime()) {
              return repeatDate;
            } else {
              switch (option) {
                case "every week":
                case "every month":
                case "every year":
                  date = moment(this.get("schedule"));
                  break;
                default:
                  date = moment(completionDate);
              }
            }
          } else {
            date = moment(completionDate);
          }
        } else {
          date = moment(this.get("schedule"));
        }
        switch (option) {
          case "every day":
            return date.add("days", 1).toDate();
          case "every week":
          case "every month":
          case "every year":
            type = option.replace("every ", "") + "s";
            if (this.has("completionDate")) {
              diff = moment(this.get("completionDate")).diff(date, type, true);
            } else {
              diff = 1;
            }
            return date.add(type, Math.ceil(diff)).toDate();
          case "mon-fri or sat+sun":
            return this.getMonFriSatSunFromDate(this.get("schedule"), date);
          default:
            return null;
        }
      },
      sanitizeDataForDuplication: function(data) {
        var prop, sanitizedData, _i, _len, _ref;
        sanitizedData = _.clone(data);
        _ref = ["id", "state", "schedule", "scheduleStr", "completionDate", "completionStr", "completionTimeStr", "repeatDate"];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          prop = _ref[_i];
          if (sanitizedData[prop]) {
            delete sanitizedData[prop];
          }
        }
        sanitizedData.schedule = this.getScheduleBasedOnRepeatDate(data.repeatDate);
        sanitizedData.repeatCount++;
        return sanitizedData;
      },
      getScheduleBasedOnRepeatDate: function(repeatDate) {
        return repeatDate;
      },
      getRepeatableDuplicate: function() {
        if (this.has("repeatDate")) {
          return new this.constructor(this.sanitizeDataForDuplication(this.toJSON()));
        } else {
          throw new Error("You're trying to repeat a task that doesn't have a repeat date");
        }
      },
      toJSON: function() {
        this.set("state", this.getState());
        return Backbone.Model.prototype.toJSON.apply(this, arguments);
      },
      cleanUp: function() {
        return this.off();
      }
    });
  });

}).call(this);
