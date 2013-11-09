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
        if (typeof this.get("schedule") === "string") {
          this.set("schedule", new Date(this.get("schedule")));
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
          _this.set("selected", false);
          _this.setCompletionStr();
          return _this.setCompletionTimeStr();
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
      setRepeatOption: function() {},
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
